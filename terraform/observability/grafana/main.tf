locals {
  grafana_url = "grafana.hl.${data.infisical_secrets.common.secrets.domain.value}"
}

resource "helm_release" "grafana" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  name       = "grafana"
  namespace  = "monitoring"
  version    = "10.5.15"
  values = [
    templatefile("${path.module}/grafana_values.yaml", {
      domain    = local.grafana_url,
      authentik = "hl.${data.infisical_secrets.common.secrets.domain.value}",
    })
  ]
}

module "grafana_authentik" {
  source = "../../modules/authentik_oauth"
  name   = "Grafana"
  slug   = "grafana"
  group  = "Infrastructure"
  url    = "https://${local.grafana_url}"
  allowed_redirect_uris = [{
    url           = "https://${local.grafana_url}/login/generic_oauth"
    matching_mode = "strict"
  }]
}

resource "kubernetes_secret_v1" "grafana_oauth" {
  metadata {
    name      = "grafana-oauth"
    namespace = "monitoring"
  }
  type = "Opaque"
  data = {
    "client_id"     = module.grafana_authentik.client_id
    "client_secret" = module.grafana_authentik.client_secret
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
    for file in fileset("${path.module}/sources/", "*.yaml") :
    file => templatefile("${path.module}/sources/${file}", {
      LOKI_URL      = data.infisical_secrets.loki.secrets.LOKI_URL.value
      LOKI_PASSWORD = data.infisical_secrets.loki.secrets.LOKI_PASSWORD.value
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
    for file in fileset("${path.module}/dashboards/", "*.json") :
    file => file("${path.module}/dashboards/${file}")
  }
}
