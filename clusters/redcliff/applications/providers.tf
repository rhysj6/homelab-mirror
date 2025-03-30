terraform {
  required_version = ">= 1.11.1"
  backend "s3" {
    bucket                      = "terraform"
    key                         = "clusters/redcliff/applications/terraform.tfstate"
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
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.12.1"
    }
  }
}

module "cluster_config" {
  source       = "rhysj6/kubeconfig/rancher"
  version      = "1.0.0"
  cluster_name = "redcliff" # TODO: Change this to the cluster name when we have a real one.
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
  kubernetes {
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
