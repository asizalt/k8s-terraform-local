# Step 1: Create the kind cluster
# Must be applied first (with -target) because the kubernetes and helm providers
# need the kubeconfig to initialize, which only exists after the cluster is created.
module "cluster" {
  source       = "./modules/cluster"
  cluster_name = var.cluster_name
}

# Write kubeconfig to disk so kubernetes/helm providers can reference it.
# The kubernetes and helm providers read this file at initialization time.
resource "local_file" "kubeconfig" {
  content         = module.cluster.kubeconfig_raw
  filename        = "${path.root}/../.kubeconfig"
  file_permission = "0600"

  depends_on = [module.cluster]
}

# Step 2: Install nginx ingress controller via Helm.
# Depends on kubeconfig existing so the helm provider can connect to the cluster.
module "ingress" {
  source = "./modules/ingress"

  depends_on = [local_file.kubeconfig]
}

# Step 3: Deploy one web-app stack per entry in var.apps.
# for_each means this module is called once per app — no code duplication.
# To add or remove apps, edit terraform.tfvars only.
module "web_app" {
  source   = "./modules/web-app"
  for_each = var.apps

  app_name          = each.key
  image             = coalesce(each.value.image, var.app_image) # falls back to var.app_image if not set
  replicas          = each.value.replicas
  path_prefix       = each.value.path_prefix
  ingress_class     = module.ingress.ingress_class_name
  container_port    = each.value.container_port
  image_pull_policy = each.value.image_pull_policy

  depends_on = [module.ingress]
}
