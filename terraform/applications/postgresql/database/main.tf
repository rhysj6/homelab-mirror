locals {
  hostname = "postgresql.cnpg-system.svc.cluster.local"
}

resource "random_string" "db_password" {
  length  = 32
  special = false
}

resource "kubernetes_secret_v1" "cnpg_db_credentials" {
  metadata {
    name      = "${var.name}-db-credentials"
    namespace = "cnpg-system"
  }
  data = {
    username = var.name
    password = random_string.db_password.result
    database = var.name
  }
  type = "Opaque"
}

resource "kubernetes_secret_v1" "app_db_credentials" {
  count = local.app_ns_exists ? 1 : 0 # Only create if namespace exists
  metadata {
    name      = "${var.name}-db-credentials"
    namespace = var.namespace
  }
  data = {
    username = var.name
    password = random_string.db_password.result
    database = var.name
    host     = local.hostname
    port     = "5432"
    uri      = "postgresql://${var.name}:${random_string.db_password.result}@${local.hostname}:5432/${var.name}"
  }
  type = "Opaque"
}


resource "kubernetes_manifest" "database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = var.name
      namespace = "cnpg-system"
    }
    spec = {
      cluster = {
        name = "postgresql"
      }
      name  = var.name
      owner = var.name
    }
  }
}
