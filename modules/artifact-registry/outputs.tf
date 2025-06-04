# Artifact Registry Repository outputs
output "repository_id" {
  description = "The ID of the Artifact Registry repository"
  value       = google_artifact_registry_repository.ecommerce_repo.id
}

output "repository_name" {
  description = "The name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.ecommerce_repo.name
}

output "repository_url" {
  description = "The URL of the Artifact Registry repository"
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ecommerce_repo.repository_id}"
}

output "repository_location" {
  description = "The location of the Artifact Registry repository"
  value       = google_artifact_registry_repository.ecommerce_repo.location
}

# CI/CD Service Account outputs
output "cicd_service_account_email" {
  description = "Email of the CI/CD service account"
  value       = google_service_account.artifact_registry_sa.email
}

output "cicd_service_account_id" {
  description = "ID of the CI/CD service account"
  value       = google_service_account.artifact_registry_sa.id
}

output "cicd_service_account_unique_id" {
  description = "Unique ID of the CI/CD service account"
  value       = google_service_account.artifact_registry_sa.unique_id
}

# Secret Manager outputs
output "cicd_key_secret_id" {
  description = "ID of the CI/CD service account key secret"
  value       = google_secret_manager_secret.artifact_registry_key.secret_id
}

output "cicd_key_secret_name" {
  description = "Name of the CI/CD service account key secret"
  value       = google_secret_manager_secret.artifact_registry_key.name
}

# Docker commands for local development
output "docker_login_command" {
  description = "Docker login command for this registry"
  value       = "gcloud auth configure-docker ${var.location}-docker.pkg.dev"
}

output "docker_tag_example" {
  description = "Example docker tag command for this registry"
  value       = "docker tag IMAGE_NAME:TAG ${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ecommerce_repo.repository_id}/IMAGE_NAME:TAG"
}

output "docker_push_example" {
  description = "Example docker push command for this registry"
  value       = "docker push ${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.ecommerce_repo.repository_id}/IMAGE_NAME:TAG"
}
