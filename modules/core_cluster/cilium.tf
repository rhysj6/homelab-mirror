
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

data "kubernetes_resources" "cilium_loadbalancer_crd" { ## Get the CRD if it exists
  api_version = "apiextensions.k8s.io/v1"
  kind        = "CustomResourceDefinition"
  field_selector = "metadata.name=ciliumloadbalancerippools.cilium.io"
  limit = 1
}

resource "kubernetes_manifest" "cilium_loadbalancer_ip_pool" {
  count = length(data.kubernetes_resources.cilium_loadbalancer_crd.objects) ## Only create the IP pool if the CRD exists (will require a re-run if the CRD is created by the Helm release)
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
  count = length(data.kubernetes_resources.cilium_loadbalancer_crd.objects) ## Only create the policy if the CRD exists (will require a re-run if the CRD is created by the Helm release)
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