resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_grafana" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "70.3.0"

  values = [
    templatefile("${path.module}/templates/values.yaml", {
      domain = "grafana.${var.cluster_domain}",
      ip_addrs = var.cluster_node_ips,
      authentik = var.authentik_url,
      authentik_slug  = "grafana-${var.cluster_name}",
    })
  ]
  # set_list {
  #   name = "kubeControllerManager.endpoints"
  #   value = var.cluster_node_ips
  # }
  # set_list {
  #   name = "kubeScheduler.endpoints"
  #   value = var.cluster_node_ips
  # }
  # set_list {
  #   name = "kubeEtcd.endpoints"
  #   value = var.cluster_node_ips
  # }
}