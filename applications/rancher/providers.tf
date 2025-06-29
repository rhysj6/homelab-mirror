terraform {
  required_version = ">= 1.11.1"
  backend "s3" {
    bucket                      = "terraform"
    key                         = "applications/rancher.tfstate"
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
      version = "3.5.4"
    }
  }
}

provider "kubernetes" {
  ignore_annotations = [
    ".*cattle\\.io.*"
  ]
  ignore_labels = [
    ".*cattle\\.io.*",
    "field\\.cattle\\.io/projectId"
  ]
}
