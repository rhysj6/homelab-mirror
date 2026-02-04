resource "helm_release" "alloy" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  name       = "alloy"
  namespace  = "monitoring"
  version    = "1.5.3"
  values = [
    file("${path.module}/alloy_values.yaml")
  ]
}

locals {
  alloy_files = { for file in fileset("${path.module}/configs", "*.alloy") :
    file => templatefile("${path.module}/configs/${file}", {
      LOKI_URL            = data.infisical_secrets.loki.secrets.LOKI_URL.value
      BASIC_AUTH_PASSWORD = data.infisical_secrets.loki.secrets.LOKI_PASSWORD.value
      TENANT              = "onsite-production"
      PROMETHEUS_URL      = "prometheus-prometheus.monitoring.svc.cluster.local:9090"
    })
  }
}

resource "kubernetes_config_map_v1" "alloy" {
  metadata {
    name      = "alloy-config"
    namespace = "monitoring"
  }

  data = local.alloy_files
}
