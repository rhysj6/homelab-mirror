terraform {
  required_version = ">= 1.11.1"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.8.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}
