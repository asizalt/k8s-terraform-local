resource "kind_cluster" "this" {
  name = var.cluster_name

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Label the node as ingress-ready so the nginx-ingress controller's
      # nodeSelector can find it and schedule onto it.
      kubeadm_config_patches = [
        <<-YAML
          kind: InitConfiguration
          nodeRegistration:
            kubeletExtraArgs:
              node-labels: "ingress-ready=true"
        YAML
      ]

      # Forward host port 80 → container port 80 so that traffic hitting
      # localhost:80 reaches the nginx-ingress controller inside the cluster.
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }

      # Forward 443 for HTTPS (available for future use).
      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
      }
    }

    # Worker node — app pods schedule here automatically.
    # Control-plane taint prevents regular pods from landing on the control-plane.
    node {
      role = "worker"
    }
  }
}
