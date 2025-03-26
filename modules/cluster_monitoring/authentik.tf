data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}

data "authentik_property_mapping_provider_scope" "scope-email" {
  name = "authentik default OAuth Mapping: OpenID 'email'"
}

data "authentik_property_mapping_provider_scope" "scope-profile" {
  name = "authentik default OAuth Mapping: OpenID 'profile'"
}

data "authentik_property_mapping_provider_scope" "scope-openid" {
  name = "authentik default OAuth Mapping: OpenID 'openid'"
}

resource "authentik_provider_oauth2" "grafana" {
  name = "${var.cluster_name} Grafana - (Managed via Terraform)"
  client_id = "grafana"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.invalidation-flow.id

  allowed_redirect_uris = [{
    url           = "https://grafana.${var.cluster_domain}/login/generic_oauth"
    matching_mode = "strict"
  }]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
}

resource "authentik_application" "grafana" {
  name              = "Grafana - ${var.cluster_name}"
  slug              = "grafana-${var.cluster_name}"
    group             = "Monitoring"
  meta_launch_url   = "https://grafana.${var.cluster_domain}"
  protocol_provider = authentik_provider_oauth2.grafana.id
}

resource "authentik_group" "grafana_admins" {
  name = "Grafana Admins - ${var.cluster_name}"
}

resource "kubernetes_secret_v1" "grafana_oauth" {
    metadata {
      name = "grafana-oauth"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }
    type = "Opaque"
    data = {
      "client_id" = authentik_provider_oauth2.grafana.client_id
      "client_secret" = authentik_provider_oauth2.grafana.client_secret
    }
}