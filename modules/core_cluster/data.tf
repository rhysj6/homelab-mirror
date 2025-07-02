locals {
    cilium_crd_exists = length(data.kubernetes_resources.cilium_crds.objects) > 0
}

data "kubernetes_resources" "cilium_crds" { ## Get the CRD if it exists
  api_version    = "apiextensions.k8s.io/v1"
  kind           = "CustomResourceDefinition"
  field_selector = "metadata.name=ciliumloadbalancerippools.cilium.io"
  limit          = 1
}
