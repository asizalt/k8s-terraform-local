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

  validation {
    condition     = var.replicas > 0
    error_message = "replicas must be at least 1."
  }
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

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "image_pull_policy" {
  description = "Image pull policy: Never (local), IfNotPresent, or Always"
  type        = string
  default     = "Never"

  validation {
    condition     = contains(["Never", "IfNotPresent", "Always"], var.image_pull_policy)
    error_message = "image_pull_policy must be one of: Never, IfNotPresent, Always."
  }
}
