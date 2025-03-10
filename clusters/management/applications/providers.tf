terraform {
    backend "s3" {
    bucket = "terraform"
    key    = "clusters/management/applications/terraform.tfstate"
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
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    infisical = {
      version = ">= 0.13.0"
      source  = "infisical/infisical"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.12.1"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    rancher2 = {
      source = "rancher/rancher2"
      version = "6.0.0"
    }
  }
}
provider "kubernetes" {
  // Handled in the environment variables.
  config_path = "/workspaces/homelab/management_kubeconfig"
  ignore_annotations = [
    ".*lifecycle\\.cattle\\.io.*",
    ".*management\\.cattle\\.io.*",
    "cattle.io/status",
    "field.cattle.io/publicEndpoints",
    "cattle.io/timestamp",
    "cnpg.io/*"
  ]
  ignore_labels = [
    ".*cattle\\.io.*",
    "cnpg.io/*"
  ]
}
provider "helm" {
  kubernetes {
    // Handled in the environment variables.
    config_path = "/workspaces/homelab/management_kubeconfig"
  }
}

provider "infisical" {
  // Handled in the environment variables.
  // INFISICAL_HOST
  // INFISICAL_UNIVERSAL_AUTH_CLIENT_ID
  // INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET
}

provider "authentik" {
  // Handled in the environment variables.
  // AUTHENTIK_URL
  // AUTHENTIK_TOKEN
}

provider "minio" {
  // Handled in the environment variables.
  // MINIO_ENDPOINT
  // MINIO_USER
  // MINIO_PASSWORD
  minio_ssl = true
}
