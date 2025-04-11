resource "random_password" "clifton_client_secret" {
  length = 128 ## This is being done this way to be able to import the secret into the authentik provider.
}

resource "authentik_provider_oauth2" "clifton" {
  name               = "Clifton - (Managed via Terraform)"
  client_id          = "jiahVbymfBlRaAdegM7I2rpAI9uaquN0AYyiyxh6"
  client_secret      = random_password.clifton_client_secret.result
  authorization_flow = data.authentik_flow.authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.domain.id
  allowed_redirect_uris = [
    {
      url           = "https://clifton.hl.${var.domain}"
      matching_mode = "strict"
    }
  ]
  authentication_flow = data.authentik_flow.authorization-flow.id
  invalidation_flow   = data.authentik_flow.invalidation-flow.id
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
  ]
}

resource "authentik_application" "clifton" {
  name              = "Clifton"
  slug              = "clifton"
  group             = "Infrastructure"
  meta_launch_url   = "https://clifton.hl.${var.domain}"
  open_in_new_tab   = true
  protocol_provider = authentik_provider_oauth2.clifton.id
}

