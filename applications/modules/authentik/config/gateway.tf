# Includes any downstream oauth applications that are configured manually.

module "clifton_authentik" {
  source = "../../../../modules/authentik_oauth"
  name   = "Clifton"
  slug   = "clifton"
  group  = "Infrastructure"
  url    = "https://clifton.hl.${var.domain}"
  allowed_redirect_uris = [{
    url           = "https://clifton.hl.${var.domain}"
    matching_mode = "strict"
  }] 
}

module "actual_budget_authentik" {
  source = "../../../../modules/authentik_oauth"
  name   = "Actual Budget"
  slug   = "actual-budget"
  group  = "Home"
  url    = "https://budget.${var.domain}"
  allowed_redirect_uris = [{
    url           = "https://budget.${var.domain}/openid/callback"
    matching_mode = "strict"
  }] 
}