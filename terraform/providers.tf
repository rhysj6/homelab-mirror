ephemeral "infisical_secret" "minio_endpoint" {
  name         = "MINIO_ENDPOINT"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers"
}
ephemeral "infisical_secret" "minio_access_key" {
  name         = "MINIO_ACCESS_KEY"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers"
}

ephemeral "infisical_secret" "minio_secret_key" {
  name         = "MINIO_SECRET_KEY"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers"
}

ephemeral "infisical_secret" "cloudflare_api_token" {
  name         = "CLOUDFLARE_API_TOKEN"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers"
}

provider "minio" {
  minio_server   = ephemeral.infisical_secret.minio_endpoint.value
  minio_user     = ephemeral.infisical_secret.minio_access_key.value
  minio_password = ephemeral.infisical_secret.minio_secret_key.value
  minio_ssl      = true
}

provider "cloudflare" {
  api_token = ephemeral.infisical_secret.cloudflare_api_token.value
}
