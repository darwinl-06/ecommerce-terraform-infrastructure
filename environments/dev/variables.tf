# Project Configuration
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "ecommerce"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

# VPC Configuration
variable "subnet_cidr_range" {
  description = "CIDR range for the private subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "pods_secondary_range_cidr" {
  description = "Secondary CIDR range for pods"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_secondary_range_cidr" {
  description = "Secondary CIDR range for services"
  type        = string
  default     = "10.2.0.0/16"
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT gateway"
  type        = bool
  default     = true
}

# GKE Configuration
variable "kubernetes_version" {
  description = "The Kubernetes version for the GKE cluster"
  type        = string
  default     = "1.27"
}

variable "gke_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}

variable "gke_min_nodes" {
  description = "Minimum number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "gke_max_nodes" {
  description = "Maximum number of nodes in the node pool"
  type        = number
  default     = 5
}

variable "gke_initial_nodes" {
  description = "Initial number of nodes in the node pool"
  type        = number
  default     = 2
}

variable "gke_disk_size" {
  description = "Disk size in GB for GKE nodes"
  type        = number
  default     = 50
}

variable "gke_disk_type" {
  description = "Disk type for GKE nodes"
  type        = string
  default     = "pd-standard"
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

variable "gke_logging_service" {
  description = "Logging service for GKE"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "gke_monitoring_service" {
  description = "Monitoring service for GKE"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

# Artifact Registry Configuration
variable "artifact_cleanup_dry_run" {
  description = "Whether cleanup policy should run in dry-run mode"
  type        = bool
  default     = false
}

variable "artifact_cleanup_keep_tags" {
  description = "Tag prefixes to keep during cleanup"
  type        = list(string)
  default     = ["latest", "main", "dev"]
}

variable "artifact_cleanup_older_than" {
  description = "Delete images older than this duration"
  type        = string
  default     = "2592000s" # 30 days
}
