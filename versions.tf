terraform {
  required_version = ">= 1.11.1"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.6.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.9.0"
    }
    infisical = {
      source = "Infisical/infisical"
      version = "0.15.37"
    }
  }
}