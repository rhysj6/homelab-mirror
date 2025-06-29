terraform {
  required_version = ">= 1.11.1"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.6.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.5.4"
    }
  }
}
