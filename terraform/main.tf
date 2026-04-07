module "cluster" {
  source       = "./modules/cluster"
  cluster_name = var.cluster_name
}

# Write kubeconfig to disk so kubernetes/helm providers can reference it
resource "local_file" "kubeconfig" {
  content         = module.cluster.kubeconfig_raw
  filename        = "${path.root}/../.kubeconfig"
  file_permission = "0600"

  depends_on = [module.cluster]
}

module "ingress" {
  source = "./modules/ingress"

  depends_on = [local_file.kubeconfig]
}

module "web_app" {
  source   = "./modules/web-app"
  for_each = var.apps

  app_name      = each.key
  image         = var.app_image
  replicas      = each.value.replicas
  path_prefix   = each.value.path_prefix
  ingress_class = module.ingress.ingress_class_name

  depends_on = [module.ingress]
}
