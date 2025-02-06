terraform {
  required_providers {
    infisical = {
      source = "infisical/infisical"
    }
  }
  backend "s3" {
    key = "secret-management/boostrap.tfstate"
  }
}

provider "infisical" {
  host = var.host
  auth = {
    universal = {
      client_id     = var.client_id
      client_secret = var.token
    }
  }
}
