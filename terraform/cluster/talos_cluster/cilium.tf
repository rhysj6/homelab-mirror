
resource "helm_release" "cilium" {
  chart       = "cilium"
  repository  = "https://helm.cilium.io"
  name        = "cilium"
  namespace   = "kube-system"
  version     = "1.19.5"
  max_history = 2
  values = [
    templatefile("${path.module}/cilium_values.yaml.tftpl", {
      control_plane_ip = var.kubevip
      native_routing_enabled = coalesce(var.network.native_routing_enabled, false)
      main_pod_cidr = coalesce(var.network.main_pod_cidr, "10.240.0.0/16")
    })
  ]

  depends_on = [talos_cluster_kubeconfig.kubeconfig]
}
