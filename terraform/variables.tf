variable "cluster_name" {
  description = "Name of the kind cluster"
  type        = string
  default     = "local-cluster"
}

variable "app_image" {
  description = "Docker image for the web app (must be loaded into kind)"
  type        = string
  default     = "local/web-app:latest"
}

variable "apps" {
  description = "Map of apps to deploy. Key = app name, value = config."
  type = map(object({
    replicas    = number
    path_prefix = string
  }))
}
