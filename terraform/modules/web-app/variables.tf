variable "app_name" {
  description = "Unique name for this application"
  type        = string
}

variable "image" {
  description = "Docker image to deploy"
  type        = string
}

variable "replicas" {
  description = "Number of pod replicas"
  type        = number
  default     = 1
}

variable "path_prefix" {
  description = "URL path prefix this app will be served at (e.g. /app-1)"
  type        = string
}

variable "ingress_class" {
  description = "Ingress class name to use"
  type        = string
  default     = "nginx"
}

variable "namespace" {
  description = "Kubernetes namespace to deploy into"
  type        = string
  default     = "default"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}
