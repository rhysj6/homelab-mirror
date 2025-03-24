terraform {
  required_version = ">= 1.11.1"
  required_providers {
    infisical = {
      source = "infisical/infisical"
      version = ">= 0.15.1"
    }
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
