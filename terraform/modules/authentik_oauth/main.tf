resource "random_password" "client_id" {
  length  = 40
}


resource "authentik_provider_oauth2" "main" {
  name               = "${var.name} - (Managed via Terraform)"
  authorization_flow = data.authentik_flow.authorization.id
  signing_key        = data.authentik_certificate_key_pair.main.id
  invalidation_flow   = data.authentik_flow.logout.id
  client_id          = random_password.client_id.result
  property_mappings = [
    data.authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.profile.id,
  ]
  allowed_redirect_uris = var.allowed_redirect_uris
}

resource "authentik_application" "main" {
  name              = var.name
  slug              = var.slug
  group             = var.group
  meta_launch_url   = var.url
  open_in_new_tab   = true
  protocol_provider = authentik_provider_oauth2.main.id
}