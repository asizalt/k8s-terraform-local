terraform {
  required_version = ">= 1.6"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
