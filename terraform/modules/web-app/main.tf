# Deploys one instance of the web app as a Kubernetes Deployment.
# This module is called once per app via for_each in the root main.tf.
resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = "web"
          image = var.image

          # "Never" for locally loaded images (kind), "IfNotPresent" for public images.
          image_pull_policy = var.image_pull_policy

          port {
            container_port = var.container_port
          }

          # Inject pod identity via the Downward API so the app can return
          # its own pod name and IP without any custom logic.
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          # Terraform waits for this probe to pass before marking the deployment
          # as complete, ensuring the app is ready before proceeding.
          readiness_probe {
            http_get {
              path = "/"
              port = var.container_port
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }
        }
      }
    }
  }
}

# ClusterIP exposes the app internally only — external traffic goes through
# the ingress controller, not directly to this service.
resource "kubernetes_service" "this" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      port        = 80
      target_port = var.container_port
    }

    type = "ClusterIP"
  }
}

# One Ingress resource per app. nginx-ingress watches all Ingress objects
# and merges them into its routing table automatically.
resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    annotations = {
      # Strip the path prefix before forwarding to the service.
      # $2 captures everything after the prefix (e.g. /app-1/foo → /foo).
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    # Routes only Ingress objects with this class to the nginx controller.
    ingress_class_name = var.ingress_class

    rule {
      http {
        path {
          # Matches /app-1, /app-1/, and /app-1/anything.
          # Group 1: the slash separator. Group 2: the remainder forwarded via rewrite.
          path      = "${var.path_prefix}(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service.this.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
