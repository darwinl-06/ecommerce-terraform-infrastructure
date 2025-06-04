# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode           = "REGIONAL"
}

# Subnet principal para GKE
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${var.vpc_name}-gke-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  # Rangos secundarios para Kubernetes
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }

  # Habilitar acceso privado a Google APIs
  private_ip_google_access = true
}

# Cloud Router para Cloud NAT
resource "google_compute_router" "router" {
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# Cloud NAT para conectividad externa de nodos privados
resource "google_compute_router_nat" "nat" {
  name   = "${var.vpc_name}-nat"
  router = google_compute_router.router.name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall Rules

# Permitir tráfico interno entre microservicios
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.vpc_name}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr, var.pods_cidr, var.services_cidr]
  
  target_tags = ["gke-node"]
}

# Permitir acceso SSH (solo para debugging)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.vpc_name}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Solo desde rangos de IP específicos (ajustar según necesidad)
  source_ranges = ["35.235.240.0/20"] # Google Cloud Shell
  target_tags   = ["ssh-access"]
}

# Permitir tráfico HTTP/HTTPS al API Gateway
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.vpc_name}-allow-web"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# Permitir healthchecks de Google Cloud Load Balancer
resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.vpc_name}-allow-health-check"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["gke-node"]
}
