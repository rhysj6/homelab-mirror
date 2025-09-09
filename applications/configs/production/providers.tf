terraform {
  required_version = ">= 1.11.1"
  backend "s3" {
    bucket                      = "terraform"
    key                         = "applications/configs/production.tfstate"
    region                      = "main"
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.8.1"
    }
  }
}

provider "authentik" {
  // Handled in the environment variables.
  // AUTHENTIK_URL
  // AUTHENTIK_TOKEN
}
