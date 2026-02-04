unit "loki" {
  source = "${get_repo_root()}/terraform/observability/loki"
  path   = "loki"
}

unit "grafana" {
  source = "${get_repo_root()}/terraform/observability/grafana"
  path   = "grafana"
  
  inputs = {
    loki_url      = dependency.loki.outputs.loki_url
    loki_password = dependency.loki.outputs.loki_password
  }
  
  dependencies = ["loki"]
}

unit "alloy" {
  source = "${get_repo_root()}/terraform/observability/alloy"
  path   = "alloy"
  
  inputs = {
    loki_url      = dependency.loki.outputs.loki_url
    loki_password = dependency.loki.outputs.loki_password
  }
  
  dependencies = ["loki"]
}
