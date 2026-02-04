# Includes any downstream oauth applications that are configured manually.

module "clifton_authentik" {
  source = "git::https://github.com/rhysj6/homelab.git//terraform/modules/authentik_oauth?ref=main"
  name   = "Clifton"
  slug   = "clifton"
  group  = "Infrastructure"
  url    = "https://clifton.hl.${local.domain}"
  allowed_redirect_uris = [{
    url           = "https://clifton.hl.${local.domain}"
    matching_mode = "strict"
  }]
  allowed_group = "pve-access"
  secure_access = true
}

module "actual_budget_authentik" {
  source = "git::https://github.com/rhysj6/homelab.git//terraform/modules/authentik_oauth?ref=main"
  name   = "Actual Budget"
  slug   = "actual-budget"
  group  = "Personal"
  url    = "https://budget.${local.domain}"
  allowed_redirect_uris = [{
    url           = "https://budget.${local.domain}/openid/callback"
    matching_mode = "strict"
  }]
  allowed_group     = "J6-personal"
  local_only_access = true
}


module "semaphore_authentik" {
  source = "git::https://github.com/rhysj6/homelab.git//terraform/modules/authentik_oauth?ref=main"
  name   = "Semaphore"
  slug   = "semaphore"
  group  = "Infrastructure"
  url    = "https://semaphore.hl.${local.domain}"
  allowed_redirect_uris = [{
    url           = "https://semaphore.hl.${local.domain}/api/auth/oidc/authentik/redirect/"
    matching_mode = "strict"
  }]
  allowed_group     = "J6-personal"
  local_only_access = true
}

resource "infisical_secret" "semaphore_client_id" {
  name         = "semaphore_CLIENT_ID"
  value        = module.semaphore_authentik.client_id
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/applications/authentik_config/outputs/"
}
resource "infisical_secret" "semaphore_client_secret" {
  name         = "semaphore_CLIENT_SECRET"
  value        = module.semaphore_authentik.client_secret
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/applications/authentik_config/outputs/"
}
