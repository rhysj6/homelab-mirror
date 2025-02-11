
resource "helm_release" "cilium" {
  chart      = "cilium"
  repository = "https://helm.cilium.io"
  name       = "cilium"
  namespace  = "kube-system"
  version    = "1.17.0"
  max_history = 2
  values = [
    "${file("${path.module}/cilium_values.yaml")}"
  ]
  set {
    name = "k8sServiceHost"
    value = var.main_node_ip
  }
  set {
    name  = "operator.replicas"
    value = var.cluster_name == "management" ? 1 : 2
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
      allowFirstLastIPs = "No"
    }
  }
  depends_on = [helm_release.cilium]
}

resource "kubernetes_manifest" "cilium_l2_announcement_policy" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"
    metadata = {
      name = "default-policy"
    }
    spec = {
      externalIPs = true
      loadBalancerIPs = true
    }
  }
  depends_on = [helm_release.cilium]
}