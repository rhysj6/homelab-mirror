terraform {
  required_providers {
    infisical = {
      source = "infisical/infisical"
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