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

output "nat_gateway_name" {
  description = "Name of the NAT gateway"
  value       = module.vpc.nat_gateway_name
}

# GKE Outputs
output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate of the GKE cluster"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}

output "workload_identity_service_account" {
  description = "Workload Identity service account email"
  value       = module.gke.workload_identity_service_account_email
}

# Artifact Registry Outputs
output "artifact_registry_url" {
  description = "URL of the Artifact Registry repository"
  value       = module.artifact_registry.repository_url
}

output "docker_login_command" {
  description = "Command to login to Docker registry"
  value       = module.artifact_registry.docker_login_command
}

output "cicd_service_account_email" {
  description = "CI/CD service account email"
  value       = module.artifact_registry.cicd_service_account_email
}

# Environment Information
output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}
