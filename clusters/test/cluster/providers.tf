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
  }
}