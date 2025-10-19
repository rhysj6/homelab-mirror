resource "kubernetes_manifest" "longhorn_postgres" {
  manifest = {
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "longhorn-postgresql"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" = "false"
      }
    }
    provisioner          = "driver.longhorn.io"
    allowVolumeExpansion = true
    volumeBindingMode    = "WaitForFirstConsumer"
    reclaimPolicy        = "Delete"
    parameters = {
      numberOfReplicas    = "1"
      staleReplicaTimeout = "1440" # 1 day
      fsType              = "ext4"
      dataLocality        = "strict-local"
    }
  }
}
