resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "75.8.0"
  values = [
    templatefile("${path.module}/templates/monitoring_values.yaml", {
      ip_addrs   = var.cluster_node_ips,
      service_ip = var.monitoring_ip,
    })
  ]
}
