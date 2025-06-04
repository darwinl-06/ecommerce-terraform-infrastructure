# VPC Module for eCommerce Microservices

variable "project_id" {
  description = "ID del proyecto de Google Cloud"
  type        = string
}

variable "region" {
  description = "Región principal para los recursos"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR para la subnet principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pods_cidr" {
  description = "CIDR para los pods de Kubernetes"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = "CIDR para los servicios de Kubernetes"
  type        = string
  default     = "10.2.0.0/16"
}
