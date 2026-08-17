locals{
  longhorn_replica_count =  length([for node in var.nodes : node if node.storage_enabled == true])
  backup_bucket_name     = "${var.cluster}-longhorn-backup"
}

resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "helm_release" "longhorn" {
  chart       = "longhorn"
  repository  = "https://charts.longhorn.io"
  name        = "longhorn"
  namespace   = kubernetes_namespace.longhorn.id
  version     = "1.12.1"
  max_history = 2
  values = [
    yamlencode({
      defaultSettings = {
        orphanAutoDeletion                          = false
        autoDeletePodWhenVolumeDetachedUnexpectedly = true
        nodeDownPodDeletionPolicy                   = "delete-both-statefulset-and-deployment-pod"
        nodeDrainPolicy                             = "always-allow"
        storageReservedPercentageForDefaultDisk     = "1"
        defaultDataPath                             = "/var/mnt/longhorn"
        deletingConfirmationFlag                     = var.cluster == "test"
      }
      persistence = {
        defaultClassReplicaCount = local.longhorn_replica_count
      }
      backupTarget = {
        backupTarget                 = "s3://${local.backup_bucket_name}@us-east-1/"
        backupTargetCredentialSecret = kubernetes_secret_v1.longhorn_backup.metadata[0].name
      }
      longhornManager = {
        nodeSelector = {
          storage_enabled = "true"
        }
      }
      longhornDriver = {
        nodeSelector = {
          storage_enabled = "true"
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "longhorn_local_storage_class" {
  manifest = {
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "longhorn-local"
      annotations = {
        "storageclass.kubernetes.io/is-default-class" = "false"
      }
    }
    provisioner          = "driver.longhorn.io"
    allowVolumeExpansion = true
    reclaimPolicy        = "Delete"
    parameters = {
      numberOfReplicas    = "1"
      staleReplicaTimeout = "1440" # 1 day
      fsType              = "ext4"
      dataLocality        = "strict-local"
    }
  }
  depends_on = [helm_release.longhorn]
}


resource "kubernetes_secret_v1" "longhorn_backup" {
  metadata {
    name      = "longhorn-b2-backup"
    namespace = kubernetes_namespace.longhorn.id
  }
  data = {
    "AWS_ACCESS_KEY_ID"     = b2_application_key.longhorn_backup.application_key_id
    "AWS_SECRET_ACCESS_KEY" = b2_application_key.longhorn_backup.application_key
    "AWS_ENDPOINTS"         = "https://s3.eu-central-003.backblazeb2.com"
  }
  type = "Opaque"
}


resource "b2_bucket" "longhorn_backup" {
  bucket_name = local.backup_bucket_name
  bucket_type = "allPrivate"

  default_server_side_encryption {
    mode      = "SSE-B2"
    algorithm = "AES256"
  }

  lifecycle_rules {
    file_name_prefix             = "*"
    days_from_hiding_to_deleting = 30
  }
}

resource "b2_application_key" "longhorn_backup" {
  key_name     = "${var.cluster}-longhorn-backup"
  capabilities = ["listBuckets", "listAllBucketNames", "listFiles", "writeFiles", "readFiles", "deleteFiles", "readBucketEncryption"]
  bucket_ids   = [b2_bucket.longhorn_backup.id]
}
