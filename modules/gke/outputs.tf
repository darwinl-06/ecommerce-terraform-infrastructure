output "cluster_name" {
  description = "Nombre del cluster GKE"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Endpoint del cluster GKE"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Certificado CA del cluster"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "Ubicación del cluster"
  value       = google_container_cluster.primary.location
}

output "service_account_email" {
  description = "Email del service account de GKE"
  value       = google_service_account.gke_service_account.email
}

output "namespace_name" {
  description = "Nombre del namespace de ecommerce"
  value       = kubernetes_namespace.ecommerce.metadata[0].name
}

output "workload_identity_service_account" {
  description = "Service account para workload identity"
  value       = kubernetes_service_account.workload_identity.metadata[0].name
}

output "kubectl_config_command" {
  description = "Comando para configurar kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}
