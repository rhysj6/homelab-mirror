terraform {
  # cloud {
  #   organization = "Homelab"
  #   workspaces {
  #     name = "Rancher_Cluster"
  #   }
  # }

  required_providers {
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
