terraform {
  required_version = ">= 1.11.1"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.11.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}
