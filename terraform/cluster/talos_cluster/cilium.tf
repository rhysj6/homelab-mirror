
resource "helm_release" "cilium" {
  chart       = "cilium"
  repository  = "https://helm.cilium.io"
  name        = "cilium"
  namespace   = "kube-system"
  version     = "1.18.4"
  max_history = 2
  values = [
    templatefile("${path.module}/cilium_values.yaml.tftpl", {
      control_plane_ip = var.kubevip
    })
  ]

  depends_on = [talos_cluster_kubeconfig.kubeconfig]
}
