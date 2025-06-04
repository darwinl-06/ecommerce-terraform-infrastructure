# Artifact Registry Module for eCommerce Microservices

variable "project_id" {
  description = "ID del proyecto de Google Cloud"
  type        = string
}

variable "location" {
  description = "Ubicación del repositorio"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "repository_id" {
  description = "ID del repositorio de Artifact Registry"
  type        = string
}

variable "description" {
  description = "Descripción del repositorio"
  type        = string
  default     = "Docker repository for eCommerce microservices"
}

variable "format" {
  description = "Formato del repositorio"
  type        = string
  default     = "DOCKER"
}

variable "cleanup_policy_dry_run" {
  description = "Ejecutar cleanup policy en modo dry run"
  type        = bool
  default     = false
}
