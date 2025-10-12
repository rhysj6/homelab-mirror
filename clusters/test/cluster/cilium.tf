
resource "helm_release" "cilium" {
  chart       = "cilium"
  repository  = "https://helm.cilium.io"
  name        = "cilium"
  namespace   = "kube-system"
  version     = "1.18.2"
  max_history = 2
  values = [
    file("${path.module}/cilium_values.yaml")
  ]

  depends_on = [ talos_cluster_kubeconfig.kubeconfig ]
}