output "kubeconfig_raw" {
  description = "Raw kubeconfig for the created cluster"
  value       = kind_cluster.this.kubeconfig
  sensitive   = true
}

output "cluster_name" {
  value = kind_cluster.this.name
}
