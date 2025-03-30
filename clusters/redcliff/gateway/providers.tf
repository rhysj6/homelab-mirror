terraform {
  required_version = ">= 1.11.1"
  backend "s3" {
    bucket                      = "terraform"
    key                         = "clusters/redcliff/gateway/terraform.tfstate"
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
    infisical = {
      version = ">= 0.13.0"
      source  = "infisical/infisical"
    }
  }
}

module "cluster_config" {
  source       = "rhysj6/kubeconfig/rancher"
  version      = "1.0.0"
  cluster_name = "test" # TODO: Change this to the cluster name when we have a real one.
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
