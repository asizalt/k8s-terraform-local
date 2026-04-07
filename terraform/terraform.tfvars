cluster_name = "local-cluster"
app_image    = "local/web-app:latest"

apps = {
  "app-1" = { replicas = 2, path_prefix = "/app-1" }
  "app-2" = { replicas = 1, path_prefix = "/app-2" }
  "app-3" = { replicas = 1, path_prefix = "/app-3" }
  "podinfo" = {
    replicas          = 1
    path_prefix       = "/podinfo"
    image             = "ghcr.io/stefanprodan/podinfo:latest"
    container_port    = 9898
    image_pull_policy = "IfNotPresent"
  }
}
