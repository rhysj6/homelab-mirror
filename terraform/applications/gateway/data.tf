locals {
  domain = data.infisical_secrets.common.secrets.domain.value
  windows_domain = data.infisical_secrets.common.secrets.windows_domain.value
}

data "infisical_secrets" "common" {
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/common"
}
