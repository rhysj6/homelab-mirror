terraform {
  required_version = ">= 1.11.1"
  backend "s3" {
    bucket                      = "terraform"
    key                         = "clusters/test/core/terraform.tfstate"
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
    minio = {
      source  = "aminueza/minio"
      version = "3.5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.6.0"
    }
  }
}

provider "kubernetes" {
  alias = "management"
  host  = module.management_cluster_config.host
  token = module.management_cluster_config.token
  ignore_annotations = [
    ".*cattle\\.io.*"
  ]
  ignore_labels = [
    ".*cattle\\.io.*"
  ]
}

module "test_cluster_config" {
  source       = "rhysj6/kubeconfig/rancher"
  version      = "1.0.0"
  cluster_name = "test"
}

provider "kubernetes" {
  host  = module.test_cluster_config.host
  token = module.test_cluster_config.token
  ignore_annotations = [
    ".*cattle\\.io.*"
  ]
  ignore_labels = [
    ".*cattle\\.io.*"
  ]
}
provider "helm" {
  kubernetes {
    host  = module.test_cluster_config.host
    token = module.test_cluster_config.token
  }
}
