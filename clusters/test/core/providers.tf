# terraform {
# cloud {
#   organization = "Homelab"
#   workspaces {
#     name = "Rancher_Cluster"
#   }
# }
# }
terraform {

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "6.0.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.2.3"
    }
    infisical = {
      version = ">= 0.13.0"
      source  = "infisical/infisical"
    }
  }
}

provider "kubernetes" {
  alias       = "management"
  config_path = "/workspaces/homelab/management_kubeconfig"
  ignore_annotations = [
    ".*cattle\\.io.*"
  ]
  ignore_labels = [
    ".*cattle\\.io.*"
  ]
}
# provider "helm" {
#   kubernetes {
#     // Handled in the environment variables.
#     config_path = "/workspaces/homelab/management_kubeconfig"
#   }
# }

provider "minio" {
  // Handled in the environment variables.
  // MINIO_ENDPOINT
  // MINIO_USER
  // MINIO_PASSWORD
  minio_ssl = true
}
