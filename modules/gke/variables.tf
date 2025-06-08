# GKE Module for eCommerce Microservices

variable "project_id" {
  description = "ID del proyecto de Google Cloud"
  type        = string
}

variable "region" {
  description = "Región para el cluster GKE"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Nombre del cluster GKE"
  type        = string
}

variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
}

variable "subnet_name" {
  description = "Nombre de la subnet"
  type        = string
}

variable "pods_range_name" {
  description = "Nombre del rango secundario para pods"
  type        = string
}

variable "services_range_name" {
  description = "Nombre del rango secundario para servicios"
  type        = string
}

variable "initial_node_count" {
  description = "Número inicial de nodos"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Número mínimo de nodos"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Número máximo de nodos"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Tipo de máquina para los nodos"
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "Tamaño del disco en GB"
  type        = number
  default     = 30
}

variable "disk_type" {
  description = "Disk type for GKE nodes"
  type        = string
  default     = "pd-standard"
}

variable "gke_preemptible" {
  description = "Whether to use preemptible nodes for GKE"
  type        = bool
  default     = false
}

variable "preemptible" {
  description = "Usar nodos preemptibles para reducir costos"
  type        = bool
  default     = false
}
