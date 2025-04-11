terraform {
  required_version = ">= 1.11.1"
    backend "s3" {
    bucket = "terraform"
    key    = "authentik/terraform.tfstate"
    region                      = "main"
    skip_region_validation      = true
    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
    use_path_style = true
  }
  required_providers {
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
