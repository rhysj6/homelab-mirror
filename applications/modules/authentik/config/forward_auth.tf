resource "authentik_provider_proxy" "protected_services" {
  name                = "Protected Services"
  external_host       = "https://hl.${var.domain}"
  cookie_domain       = var.domain
  authorization_flow  = data.authentik_flow.authorization-flow.id
  authentication_flow = authentik_flow.authentication.uuid
  invalidation_flow   = data.authentik_flow.invalidation-flow.id
  mode                = "forward_domain"
}

resource "authentik_application" "protected_services" {
  name              = "Protected Services"
  slug              = "protected-services"
  meta_launch_url   = "blank://blank"
  protocol_provider  = authentik_provider_proxy.protected_services.id
}