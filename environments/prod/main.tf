# Production Environment Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.84"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.84"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
  
  # Backend configuration - update with your GCS bucket
  backend "gcs" {
    bucket = "ecommerce-terraform-state-prod"
    prefix = "terraform/state"
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
}

# Get access token for Kubernetes provider
data "google_client_config" "default" {}

# Local variables
locals {
  environment = "prod"
  common_tags = {
    Environment = "production"
    Project     = "ecommerce"
    ManagedBy   = "terraform"
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  project_id   = var.project_id
  region       = var.region
  environment  = local.environment
  
  # VPC Configuration
  vpc_name = "${var.project_name}-vpc-${local.environment}"
  
  # Subnet Configuration
  subnet_cidr_range              = var.subnet_cidr_range
  pods_secondary_range_name      = "pods-${local.environment}"
  pods_secondary_range_cidr      = var.pods_secondary_range_cidr
  services_secondary_range_name  = "services-${local.environment}"
  services_secondary_range_cidr  = var.services_secondary_range_cidr
  
  # NAT Configuration
  create_nat_gateway = var.create_nat_gateway
  nat_router_name    = "${var.project_name}-router-${local.environment}"
  nat_gateway_name   = "${var.project_name}-nat-${local.environment}"
}

# GKE Module
module "gke" {
  source = "../../modules/gke"
  
  project_id  = var.project_id
  region      = var.region
  environment = local.environment
  
  # Cluster Configuration
  cluster_name     = "${var.project_name}-cluster-${local.environment}"
  kubernetes_version = var.kubernetes_version
  
  # Network Configuration
  network_name    = module.vpc.vpc_name
  subnet_name     = module.vpc.private_subnet_name
  pods_range_name = module.vpc.pods_secondary_range_name
  services_range_name = module.vpc.services_secondary_range_name
  
  # Node Pool Configuration
  node_pool_name         = "${var.project_name}-nodes-${local.environment}"
  machine_type          = var.gke_machine_type
  min_node_count        = var.gke_min_nodes
  max_node_count        = var.gke_max_nodes
  initial_node_count    = var.gke_initial_nodes
  disk_size_gb          = var.gke_disk_size
  disk_type             = var.gke_disk_type
  gke_preemptible       = var.gke_preemptible
  
  # Security Configuration
  enable_workload_identity = var.enable_workload_identity
  enable_network_policy    = var.enable_network_policy
  
  # Logging and Monitoring
  logging_service    = var.gke_logging_service
  monitoring_service = var.gke_monitoring_service
  
  depends_on = [module.vpc]
}

# Artifact Registry Module
module "artifact_registry" {
  source = "../../modules/artifact-registry"
  
  project_id  = var.project_id
  location    = var.region
  environment = local.environment
  
  # Repository Configuration
  repository_id  = "${var.project_name}-repo-${local.environment}"
  description    = "Docker repository for eCommerce microservices (${local.environment})"
  
  # Cleanup Policy
  cleanup_policy_dry_run = var.artifact_cleanup_dry_run
  cleanup_keep_tag_prefixes = var.artifact_cleanup_keep_tags
  cleanup_older_than = var.artifact_cleanup_older_than
  
  # CI/CD Service Account
  cicd_service_account_id = "${var.project_name}-cicd-${local.environment}"
  
  depends_on = [module.gke]
}
