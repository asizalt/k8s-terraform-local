resource "kind_cluster" "this" {
  name = var.cluster_name

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Label the node so nginx-ingress can schedule onto it (needed later)
      kubeadm_config_patches = [
        <<-YAML
          kind: InitConfiguration
          nodeRegistration:
            kubeletExtraArgs:
              node-labels: "ingress-ready=true"
        YAML
      ]

      # Map host port 80 → container port 80 for ingress traffic (needed later)
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
      }
    }
  }
}
