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
}

module "actual_budget_authentik" {
  source = "git::https://github.com/rhysj6/homelab.git//terraform/modules/authentik_oauth?ref=main"
  name   = "Actual Budget"
  slug   = "actual-budget"
  group  = "Home"
  url    = "https://budget.${local.domain}"
  allowed_redirect_uris = [{
    url           = "https://budget.${local.domain}/openid/callback"
    matching_mode = "strict"
  }] 
}