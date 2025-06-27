locals {
  grafana_url = "grafana.hl.${var.domain}"
}

resource "helm_release" "grafana" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  name       = "grafana"
  namespace  = "monitoring"
  version    = "9.2.9"
  values = [
    templatefile("${path.module}/templates/grafana_values.yaml", {
      domain    = local.grafana_url,
      authentik = "hl.${var.domain}",
    })
  ]
}

resource "authentik_provider_oauth2" "grafana" {
  name               = "Grafana - (Managed via Terraform)"
  client_id          = "grafana"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.invalidation-flow.id

  allowed_redirect_uris = [{
    url           = "https://${local.grafana_url}/login/generic_oauth"
    matching_mode = "strict"
  }]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
}

resource "authentik_application" "grafana" {
  name              = "Grafana"
  slug              = "grafana"
  group             = "Infrastructure"
  meta_launch_url   = "https://${local.grafana_url}"
  protocol_provider = authentik_provider_oauth2.grafana.id
}

resource "kubernetes_secret_v1" "grafana_oauth" {
  metadata {
    name      = "grafana-oauth"
    namespace = "monitoring"
  }
  type = "Opaque"
  data = {
    "client_id"     = authentik_provider_oauth2.grafana.client_id
    "client_secret" = authentik_provider_oauth2.grafana.client_secret
  }
}

resource "kubernetes_config_map_v1" "grafana_data_sources" {
  metadata {
    name      = "grafana-datasources"
    namespace = "monitoring"
    labels = {
      grafana_datasource = "1"
    }
  }

  data = {
    for file in fileset("${path.module}/grafana_configs/sources/", "*.yaml") :
    file => templatefile("${path.module}/grafana_configs/sources/${file}", {
      LOKI_URL = local.loki_url
      LOKI_PASSWORD = random_password.loki_password.result
    })
  }
}

resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    for file in fileset("${path.module}/grafana_configs/dashboards/", "*.json") :
    file => file("${path.module}/grafana_configs/dashboards/${file}")
  }
}

