terraform {
required_version = ">= 1.11.1"
  backend "s3" {
    bucket                      = "terraform"
    key                         = "clusters/test/talos/terraform.tfstate"
    region                      = "main"
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }

  required_providers {
    talos = {
      source = "siderolabs/talos"
      version = "0.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    infisical = {
      source = "Infisical/infisical"
      version = "0.15.37"
    }
  }
}

provider "kubernetes" {
    host = local.k8s_host
    cluster_ca_certificate = local.k8s_cluster_ca_certificate
    client_certificate = local.k8s_client_certificate
    client_key = local.k8s_client_key
}

provider "helm" {
  kubernetes = {
    host                   = local.k8s_host
    cluster_ca_certificate = local.k8s_cluster_ca_certificate
    client_certificate     = local.k8s_client_certificate
    client_key             = local.k8s_client_key
  }
}