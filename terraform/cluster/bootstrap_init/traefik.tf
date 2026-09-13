resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  chart       = "traefik"
  repository  = "https://traefik.github.io/charts"
  name        = "traefik"
  namespace   = kubernetes_namespace.traefik.id
  version     = "41.5.0"
  max_history = 2
  depends_on  = [kubernetes_namespace.traefik, helm_release.kube_prometheus_stack]
  values = [
    templatefile("${path.module}/templates/traefik_values.yaml", {
      service_ip  = var.network.ips.ingress_controller,
      cluster_name = var.cluster,
    })
  ]
}


resource "netbox_ip_address" "ingress_vip" {
  ip_address  = "${var.network.ips.ingress_controller}/24"
  description = "K8S ${title(var.cluster)} ingress controller"
  status      = "active"
  role        = "vip"
}
