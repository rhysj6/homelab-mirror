resource "helm_release" "alloy" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  name       = "alloy"
  namespace  = "monitoring"
  version    = "1.0.3"
  values = [
    file("${path.module}/templates/alloy_values.yaml")
  ]
}

locals {
  alloy_files = { for file in fileset("${path.module}/alloy_configs", "*.alloy") :
    file => templatefile("${path.module}/alloy_configs/${file}", {
      LOKI_URL            = local.loki_url
      BASIC_AUTH_PASSWORD = random_password.loki_password.result
      TENANT              = "onsite-production"
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
