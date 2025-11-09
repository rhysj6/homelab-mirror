locals {
  url = "hl.${data.infisical_secrets.common.secrets.domain.value}"
}

data "infisical_secrets" "common" {
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/common"
}

data "infisical_secrets" "db_creds" {
  env_slug     = "${var.env}"
  workspace_id = "2ace56f5-d07e-455e-9009-e44dfce28566"
  folder_path  = "/db-creds/"
}

