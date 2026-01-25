terraform {
  required_version = ">= 1.11.1"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.11.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.12.0"
    }
    infisical = {
      source  = "Infisical/infisical"
      version = "0.15.60"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.12.0"
    }
  }
}
