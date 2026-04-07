output "cluster_name" {
  value = module.cluster.cluster_name
}

output "kubeconfig_path" {
  description = "Path to the written kubeconfig file"
  value       = local_file.kubeconfig.filename
}

output "app_urls" {
  description = "Local URLs for each deployed application"
  value = {
    for name, app in module.web_app :
    name => "http://localhost${app.ingress_path}"
  }
}
