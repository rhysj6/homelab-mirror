terraform {
  required_version = ">= 1.11.1"
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "7.0.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.5.0"
    }
  }
}