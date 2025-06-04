output "vpc_id" {
  description = "ID de la VPC creada"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "Nombre de la VPC creada"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "ID de la subnet principal"
  value       = google_compute_subnetwork.gke_subnet.id
}

output "subnet_name" {
  description = "Nombre de la subnet principal"
  value       = google_compute_subnetwork.gke_subnet.name
}

output "pods_range_name" {
  description = "Nombre del rango de IPs para pods"
  value       = "pods"
}

output "services_range_name" {
  description = "Nombre del rango de IPs para servicios"
  value       = "services"
}

output "region" {
  description = "Región donde se desplegó la infraestructura"
  value       = var.region
}
