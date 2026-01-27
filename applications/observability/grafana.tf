locals {
  grafana_url = "grafana.hl.${var.domain}"
}

resource "helm_release" "grafana" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  name       = "grafana"
  namespace  = "monitoring"
  version    = "10.5.13"
  values = [
    templatefile("${path.module}/templates/grafana_values.yaml", {
      domain    = local.grafana_url,
      authentik = "hl.${var.domain}",
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
    for file in fileset("${path.module}/grafana_configs/sources/", "*.yaml") :
    file => templatefile("${path.module}/grafana_configs/sources/${file}", {
      LOKI_URL      = local.loki_url
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

