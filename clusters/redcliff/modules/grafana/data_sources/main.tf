locals {
  path = "${path.module}/sources"
}

resource "kubernetes_config_map" "grafana_data_sources" {
  for_each = fileset(local.path, "*.yaml")
  metadata {
    name      = "${trimsuffix(each.key, ".yaml")}-grafana-datasource"
    namespace = "monitoring"
    labels = {
      grafana_datasource = "1"
    }
  }

  data = {
    (each.key) = file("${local.path}/${each.key}")
  }
}