
resource "helm_release" "cilium" {
  chart      = "cilium"
  repository = "https://helm.cilium.io"
  name       = "cilium"
  namespace  = "kube-system"
  version    = "1.17.0"
  max_history = 2
  values = [
    "${file("cilium_values.yaml")}"
  ]
  set {
    name = "k8sServiceHost"
    value = var.main_node_ip
  }
  set {
    name = "ingressController.service.annotations.lbipam\\.cilium\\.io/ips"
    value = var.ingress_controller_ip
  }
}

resource "kubernetes_manifest" "cilium_loadbalancer_ip_pool" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "main-pool"
    }
    spec = {
      blocks = [
        {
          cidr = var.cilium_loadbalancer_ip_pool_cidr
        }
      ]
    }
  }
  depends_on = [helm_release.cilium]
}