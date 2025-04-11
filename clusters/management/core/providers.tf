terraform {
    required_version = ">= 1.11.1"
    backend "s3" {
    bucket = "terraform"
    key    = "clusters/management/core/terraform.tfstate"
    region                      = "main"
    skip_region_validation      = true
    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
    use_path_style = true
  }
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
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

provider "minio" {
  // Handled in the environment variables.
  // MINIO_ENDPOINT
  // MINIO_USER
  // MINIO_PASSWORD
  minio_ssl = true
}

provider "kubernetes" {
  // Handled in the environment variables.
  config_path = "/workspaces/homelab/management_kubeconfig"
    ignore_annotations = [
    ".*cattle\\.io.*"
  ]
  ignore_labels = [
    ".*cattle\\.io.*"
  ]
}
provider "helm" {
  kubernetes {
    // Handled in the environment variables.
    config_path = "/workspaces/homelab/management_kubeconfig"
  }
}