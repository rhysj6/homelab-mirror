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
  version    = "89.1.0"
  values = [
    templatefile("${path.module}/templates/monitoring_values.yaml", {
      ip_addrs   = [for node in var.nodes : node.ip_address],
      service_ip = var.network.ips.monitoring,
      cluster_name = var.cluster,
    })
  ]
}

resource "netbox_ip_address" "monitoring_vip" {
  ip_address  = "${var.network.ips.monitoring}/24"
  description = "K8S ${title(var.cluster)} monitoring"
  status      = "active"
  role        = "vip"
}