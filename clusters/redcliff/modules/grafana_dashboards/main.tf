resource "kubernetes_config_map" "grafana_dashboards" {
  for_each = fileset(path.module, "*.json")
  metadata {
    name      = trimsuffix(each.key, ".json")
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    (each.key) = file("${path.module}/${each.key}")
  }
}