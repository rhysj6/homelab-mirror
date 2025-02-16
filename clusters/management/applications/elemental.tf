data "rancher2_cluster" "management" {
  name = "local"
}
data "rancher2_project" "system" {
  cluster_id = data.rancher2_cluster.management.id
  name       = "System"
}

resource "kubernetes_namespace" "elemental" {
  metadata {
    name = "cattle-elemental-system"
    annotations = {
      "field.cattle.io/projectId" = data.rancher2_project.system.id
    }
  }
  depends_on = [helm_release.rancher]
}

resource "helm_release" "elemental_crds" {
  name       = "elemental-operator-crds"
  chart      = "oci://registry.suse.com/rancher/elemental-operator-crds-chart"
  version    = "1.6.5"
  namespace  = kubernetes_namespace.elemental.id
  depends_on = [kubernetes_namespace.elemental]
}

resource "helm_release" "elemental" {
  name       = "elemental-operator"
  chart      = "oci://registry.suse.com/rancher/elemental-operator-chart"
  version    = "1.6.5"
  namespace  = kubernetes_namespace.elemental.id
  depends_on = [helm_release.elemental_crds, kubernetes_namespace.elemental]
}

resource "kubernetes_manifest" "micro_linux_bare_metal_os_version_channel" {
  manifest = {
    apiVersion = "elemental.cattle.io/v1beta1"
    kind       = "ManagedOSVersionChannel"
    metadata = {
      name      = "suse-micro-linux-bare-metal"
      namespace = "fleet-default"
    }
    spec = {
      options = {
        image = "registry.suse.com/rancher/elemental-channel/sl-micro:6.0-baremetal"
      }
      syncInterval = "1h"
      type         = "custom"
    }
  }
}

resource "kubernetes_manifest" "micro_linux_kvm_os_version_channel" {
  manifest = {
    apiVersion = "elemental.cattle.io/v1beta1"
    kind       = "ManagedOSVersionChannel"
    metadata = {
      name      = "suse-micro-linux-kvm"
      namespace = "fleet-default"
    }
    spec = {
      options = {
        image = "registry.suse.com/rancher/elemental-channel/sl-micro:6.0-kvm"
      }
      syncInterval = "1h"
      type         = "custom"
    }
  }
}
