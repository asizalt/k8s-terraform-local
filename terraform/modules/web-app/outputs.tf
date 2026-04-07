output "ingress_path" {
  description = "The URL path prefix this app is served at"
  value       = var.path_prefix
}

output "service_name" {
  value = kubernetes_service.this.metadata[0].name
}

output "namespace" {
  value = var.namespace
}
