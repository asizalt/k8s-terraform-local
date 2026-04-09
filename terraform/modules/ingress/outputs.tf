output "ingress_class_name" {
  description = "Ingress class name to reference in Ingress resources"
  value       = "nginx"
}

output "namespace" {
  value = var.namespace
}
