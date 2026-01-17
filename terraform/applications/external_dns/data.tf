
data "infisical_secrets" "common" {
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/common"
}

data "infisical_secrets" "dns" {
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/applications/dns"
}

data "kubernetes_namespace" "dns" {
  metadata {
    name = "dns"
  }
}

locals {
  dns_zones = [
    data.infisical_secrets.common.secrets.domain.value
  ]
}