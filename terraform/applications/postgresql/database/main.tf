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

resource "infisical_secret" "username" {
  name         = "${upper(var.name)}_USERNAME"
  value        = var.name
  env_slug     = var.env
  workspace_id = "2ace56f5-d07e-455e-9009-e44dfce28566"
  folder_path  = "/db-creds/"
}

resource "infisical_secret" "password" {
  name         = "${upper(var.name)}_PASSWORD"
  value        = random_string.db_password.result
  env_slug     = var.env
  workspace_id = "2ace56f5-d07e-455e-9009-e44dfce28566"
  folder_path  = "/db-creds/"
}
