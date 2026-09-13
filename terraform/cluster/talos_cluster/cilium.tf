
resource "helm_release" "cilium" {
  chart       = "cilium"
  repository  = "https://helm.cilium.io"
  name        = "cilium"
  namespace   = "kube-system"
  version     = "1.20.1"
  max_history = 2
  values = [
    templatefile("${path.module}/cilium_values.yaml.tftpl", {
      control_plane_ip       = var.network.ips.kubevip
      native_routing_enabled = coalesce(var.network.native_routing_enabled, false)
      main_pod_cidr          = coalesce(var.network.main_pod_cidr, "10.240.0.0/16")
    })
  ]

  depends_on = [talos_cluster_kubeconfig.kubeconfig]
}


resource "netbox_prefix" "pod_ip_pool" {
  prefix      = var.network.main_pod_cidr
  status      = "active"
  description = "K8S ${title(var.cluster)} main pod pool"
  is_pool     = true
}


resource "netbox_ip_address" "kube_vip" {
  ip_address  = "${var.network.ips.kubevip}/${var.network.node_subnet_size}"
  description = "K8S ${title(var.cluster)} Kube API VIP"
  status      = "active"
  role        = "vip"
}
