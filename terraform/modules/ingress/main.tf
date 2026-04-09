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

  # Tolerate the control-plane taint so nginx can schedule there.
  # Required now that a worker node exists and Kubernetes enforces taints strictly.
  set {
    name  = "controller.tolerations[0].key"
    value = "node-role.kubernetes.io/control-plane"
  }
  set {
    name  = "controller.tolerations[0].operator"
    value = "Equal"
  }
  set {
    name  = "controller.tolerations[0].effect"
    value = "NoSchedule"
  }

  # Wait until the controller is fully ready before Terraform proceeds
  wait    = true
  timeout = 300
}
