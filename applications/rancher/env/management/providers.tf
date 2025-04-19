terraform {
  required_version = ">= 1.11.1"
  backend "s3" {
    bucket                      = "terraform"
    key                         = "applications/rancher/env/management.tfstate"
    region                      = "main"
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  config_path = "/workspaces/homelab/management_kubeconfig"
  ignore_annotations = [
    ".*cattle\\.io.*"
  ]
  ignore_labels = [
    ".*cattle\\.io.*",
    "field\\.cattle\\.io/projectId"
  ]
}
provider "helm" {
  kubernetes {
    config_path = "/workspaces/homelab/management_kubeconfig"
  }
}
