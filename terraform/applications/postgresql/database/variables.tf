variable "name" {
  description = "The name of the database to create."
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace where a secret for the database credentials will be created."
  type        = string
}

data "kubernetes_all_namespaces" "allns" {}

locals {
  app_ns_exists = contains(data.kubernetes_all_namespaces.allns.namespaces, var.namespace)
}