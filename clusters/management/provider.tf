terraform {
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
      version = "2024.6.1" ## TODO: Update this when redeploying authentik.
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }

  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "infisical" {
  host = var.infisical.host
  auth = {
    universal = {
      client_id     = var.infisical.machine_id
      client_secret = var.infisical.token
    }
  }
}

provider "authentik" {
  url   = "https://${var.authentik_host}"
  token = data.infisical_secrets.bootstrap_secrets.secrets["authentik_token"].value
}

provider "minio" {
  minio_server   = data.infisical_secrets.bootstrap_secrets.secrets["minio_endpoint"].value
  minio_user     = data.infisical_secrets.bootstrap_secrets.secrets["minio_key"].value
  minio_password = data.infisical_secrets.bootstrap_secrets.secrets["minio_token"].value
  minio_ssl      = true
}
