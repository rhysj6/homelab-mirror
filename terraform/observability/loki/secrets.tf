resource "infisical_secret" "loki_url" {
  name         = "LOKI_URL"
  value        = local.loki_url
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/applications/loki"
}

resource "infisical_secret" "loki_password" {
  name         = "LOKI_PASSWORD"
  value        = random_password.loki_password.result
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/applications/loki"
}
