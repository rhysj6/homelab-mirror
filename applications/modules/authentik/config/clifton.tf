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