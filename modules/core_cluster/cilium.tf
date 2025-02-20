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
}