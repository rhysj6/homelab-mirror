terraform {
  required_version = ">= 1.11.1"
  backend "s3" {
    bucket                      = "terraform"
    key                         = "applications/observability/terraform.tfstate"
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
      version = "2.38.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.5.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.6.0"
    }
  }
}

module "cluster_config" {
  source       = "rhysj6/kubeconfig/rancher"
  version      = "1.1.0"
  cluster_name = "redcliff"
}

provider "kubernetes" {
  host  = module.cluster_config.host
  token = module.cluster_config.token
  ignore_annotations = [
    ".*cattle\\.io.*"
  ]
  ignore_labels = [
    ".*cattle\\.io.*"
  ]
}
provider "helm" {
  kubernetes = {
    host  = module.cluster_config.host
    token = module.cluster_config.token
  }
}

provider "minio" {
  // Handled in the environment variables.
  // MINIO_ENDPOINT
  // MINIO_USER
  // MINIO_PASSWORD
  minio_ssl = true
}
