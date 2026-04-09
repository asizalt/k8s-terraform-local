resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  # Required for kind: bind directly to the node's host ports
  set {
    name  = "controller.hostPort.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  # Only schedule on nodes labelled ingress-ready=true
  # type = "string" prevents Helm from coercing "true" to a boolean
  set {
    name  = "controller.nodeSelector.ingress-ready"
    value = "true"
    type  = "string"
  }


  # Wait until the controller is fully ready before Terraform proceeds
  wait    = true
  timeout = 300
}
