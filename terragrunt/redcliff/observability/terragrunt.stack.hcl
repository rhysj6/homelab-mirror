unit "loki" {
  source = "${get_repo_root()}/terraform/observability/loki"
  path   = "loki"
}

unit "grafana" {
  source = "${get_repo_root()}/terraform/observability/grafana"
  path   = "grafana"
}

unit "alloy" {
  source = "${get_repo_root()}/terraform/observability/alloy"
  path   = "alloy"
}
