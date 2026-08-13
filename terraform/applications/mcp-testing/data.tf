data "cloudflare_zone" "main" {
  filter = {
    name = "example.com"
  }
}

data "kubernetes_config_map_v1" "tunnel" {
  metadata {
    name = "main-tunnel-domain"
    namespace = "cloudflared"
  }
}
data "authentik_flow" "authorization" {
  slug = "default-provider-authorization-implicit-consent"
}
data "authentik_flow" "logout" {
  slug = "default-provider-invalidation-flow"
}
data "authentik_certificate_key_pair" "main" {
  name = "domain"
}
data "authentik_property_mapping_provider_scope" "email" {
  name = "authentik default OAuth Mapping: OpenID 'email'"
}
data "authentik_property_mapping_provider_scope" "profile" {
  name = "authentik default OAuth Mapping: OpenID 'profile'"
}
data "authentik_property_mapping_provider_scope" "openid" {
  name = "authentik default OAuth Mapping: OpenID 'openid'"
}