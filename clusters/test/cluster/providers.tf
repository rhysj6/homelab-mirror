terraform {
  required_version = ">= 1.11.1"
  backend "s3" {
    bucket                      = "terraform"
    key                         = "clusters/test/cluster/terraform.tfstate"
    region                      = "main"
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "8.1.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.6.5"
    }
  }
}
