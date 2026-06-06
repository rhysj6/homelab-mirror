terraform {
  required_version = ">= 1.11.1"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.38.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.19.1"
    }
    infisical = {
      source  = "Infisical/infisical"
      version = "0.16.28"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.109.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2026.2.0"
    }
    netbox = {
      source  = "e-breuninger/netbox"
      version = "5.4.0"
    }
  }
}
