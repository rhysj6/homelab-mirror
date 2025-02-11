terraform {
  # cloud {
  #   organization = "Homelab"
  #   workspaces {
  #     name = "Rancher_Cluster"
  #   }
  # }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    infisical = {
      version = ">= 0.13.0"
      source  = "infisical/infisical"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.6.1" ## TODO: Update this when redeploying authentik.
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }

  }
}
provider "kubernetes" {
  // Handled in the environment variables.
  config_path = "/workspaces/homelab/management_kubeconfig"
}
provider "helm" {
  kubernetes {
    // Handled in the environment variables.
    config_path = "/workspaces/homelab/management_kubeconfig"
  }
}