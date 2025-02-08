
data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_certificate_key_pair" "authentik_host" {
  name = local.authentik_host
}

# data "authentik_property_mapping_provider_scope" "scope-email" {
#   name = "authentik default OAuth Mapping: OpenID 'email'"
# }

# data "authentik_property_mapping_provider_scope" "scope-profile" {
#   name = "authentik default OAuth Mapping: OpenID 'profile'"
# }

# data "authentik_property_mapping_provider_scope" "scope-openid" {
#   name = "authentik default OAuth Mapping: OpenID 'openid'"
# }
