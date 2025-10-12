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
    host = "https://${local.kubevip}:6443"
    cluster_ca_certificate = talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.ca_certificate
    client_certificate = talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_certificate
    client_key = talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_key
}

provider "helm" {
  kubernetes = {
    host                   = "https://${local.kubevip}:6443"
    cluster_ca_certificate = base64decode(talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.ca_certificate)
    client_certificate     = base64decode(talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(talos_cluster_kubeconfig.kubeconfig.kubernetes_client_configuration.client_key)
  }
}