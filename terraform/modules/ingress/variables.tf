variable "namespace" {
  description = "Namespace to install nginx ingress controller into"
  type        = string
  default     = "ingress-nginx"
}

variable "chart_version" {
  description = "Helm chart version for ingress-nginx"
  type        = string
  default     = "4.10.0"
}
