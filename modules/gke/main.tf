# Service Account para nodos GKE
resource "google_service_account" "gke_service_account" {
  account_id   = "${var.cluster_name}-sa"
  display_name = "GKE Service Account for ${var.cluster_name}"
  description  = "Service account for GKE nodes in ${var.environment} environment"
}

# Roles necesarios para el service account
resource "google_project_iam_member" "gke_service_account_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# Cluster GKE
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  # Configuración de red
  network    = var.vpc_name
  subnetwork = var.subnet_name

  # Configuración de IP aliasing para usar rangos secundarios
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Configuración de nodos por defecto (será removida después de crear node pool)
  remove_default_node_pool = true
  initial_node_count       = 1

  # Configuración de red privada
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"

    master_global_access_config {
      enabled = true
    }
  }

  # Habilitar Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Configuración de master authorized networks (permitir acceso desde cualquier lugar)
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks"
    }
  }

  # Configuración de addons
  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    network_policy_config {
      disabled = false
    }

    gcp_filestore_csi_driver_config {
      enabled = true
    }

    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }

  # Habilitar network policy
  network_policy {
    enabled = true
  }

  # Configuración de logging y monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  # Configuración de release channel
  release_channel {
    channel = "REGULAR"
  }
  
  # Configuración de mantenimiento - Ventana diaria de 4 horas (2:00 AM - 6:00 AM UTC)
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  # Labels
  resource_labels = {
    environment = var.environment
    project     = "ecommerce-microservices"
    managed_by  = "terraform"
  }

  depends_on = [
    google_service_account.gke_service_account,
    google_project_iam_member.gke_service_account_roles
  ]
}

# Node Pool principal
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name

  # Configuración de autoscaling
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # Configuración inicial de nodos
  initial_node_count = var.initial_node_count

  # Configuración de nodos
  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = "pd-standard"
    
    # Usar nodos preemptibles en dev para reducir costos
    preemptible = var.preemptible

    # Service Account
    service_account = google_service_account.gke_service_account.email

    # Scopes OAuth para el service account
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]

    # Tags de red
    tags = ["gke-node", "${var.cluster_name}-node"]

    # Configuración de Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Metadata
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Labels
    labels = {
      environment = var.environment
      node_pool   = "primary"
    }

    # Taints para nodos especializados si es necesario
    # taint {
    #   key    = "microservices"
    #   value  = "true"
    #   effect = "NO_SCHEDULE"
    # }
  }

  # Configuración de gestión de nodos
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Configuración de actualización
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  depends_on = [
    google_container_cluster.primary
  ]
}

# Namespace para ecommerce
resource "kubernetes_namespace" "ecommerce" {
  metadata {
    name = "ecommerce"
    
    labels = {
      name        = "ecommerce"
      environment = var.environment
    }
  }

  depends_on = [google_container_cluster.primary]
}

# Service Account de Kubernetes para workload identity
resource "kubernetes_service_account" "workload_identity" {
  metadata {
    name      = "ecommerce-workload-identity"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
    
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.gke_service_account.email
    }
  }

  depends_on = [kubernetes_namespace.ecommerce]
}
