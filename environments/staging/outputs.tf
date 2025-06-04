# Staging Environment Outputs

# VPC Outputs
output "vpc_name" {
  description = "Name of the VPC"
  value       = module.vpc.vpc_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = module.vpc.private_subnet_name
}

output "private_subnet_cidr" {
  description = "CIDR range of the private subnet"
  value       = module.vpc.private_subnet_cidr
}

# GKE Outputs
output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "GKE cluster location"
  value       = module.gke.cluster_location
}

output "node_pool_name" {
  description = "Name of the GKE node pool"
  value       = module.gke.node_pool_name
}

output "workload_identity_service_account_email" {
  description = "Email of the Workload Identity service account"
  value       = module.gke.workload_identity_service_account_email
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}

# Artifact Registry Outputs
output "repository_url" {
  description = "URL of the Artifact Registry repository"
  value       = module.artifact_registry.repository_url
}

output "repository_name" {
  description = "Name of the Artifact Registry repository"
  value       = module.artifact_registry.repository_name
}

output "cicd_service_account_email" {
  description = "Email of the CI/CD service account"
  value       = module.artifact_registry.cicd_service_account_email
}

output "docker_login_command" {
  description = "Docker login command for Artifact Registry"
  value       = module.artifact_registry.docker_login_command
}

# Environment Information
output "environment" {
  description = "Environment name"
  value       = "staging"
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}
