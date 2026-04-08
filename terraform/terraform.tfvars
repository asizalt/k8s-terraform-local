cluster_name = "local-cluster"
app_image    = "local/web-app:latest" # default image used by all apps unless overridden per-app

# This is the only file you need to edit to add, remove, or configure apps.
# Each key becomes the app name, path prefix, and Kubernetes resource names.
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
