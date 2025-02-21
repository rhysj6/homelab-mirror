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

module "management_cluster_config" {
  source          = "../../../modules/rancher_cluster_config"
  cluster_name    = "local"
  fleet_namespace = "fleet-local"
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
  source       = "../../../modules/rancher_cluster_config"
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

provider "minio" {
  // Handled in the environment variables.
  // MINIO_ENDPOINT
  // MINIO_USER
  // MINIO_PASSWORD
  minio_ssl = true
}
