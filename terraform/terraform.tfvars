cluster_name = "local-cluster"
app_image    = "local/web-app:latest"

apps = {
  "app-1" = { replicas = 2, path_prefix = "/app-1" }
  "app-2" = { replicas = 1, path_prefix = "/app-2" }
}
