resource "helm_release" "alloy" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  name       = "alloy"
  namespace  = "monitoring"
  version    = "0.12.5"
  set {
    name  = "alloy.configMap.create"
    value = false
  }
  set {
    name = "alloy.configMap.name"
    value = "alloy-config"
  }
    set {
    name  = "alloy.configMap.key"
    value = "."
  }
}

locals {
  alloy_files = { for file in fileset("${path.module}/alloy_configs", "*.alloy") :
    file => templatefile("${path.module}/alloy_configs/${file}", {
        LOKI_URL = local.loki_url
        BASIC_AUTH_USERNAME = random_password.loki_username.result
        BASIC_AUTH_PASSWORD = random_password.loki_password.result
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