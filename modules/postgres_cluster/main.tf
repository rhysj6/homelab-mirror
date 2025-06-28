locals {
  name_prefix = "${var.name}-postgres"
}
resource "minio_iam_service_account" "backup" {
  target_user = "${var.cluster_name}-postgres-backup"
}

resource "random_password" "superuser" {
  count   = var.is_superuser_password_same ? 0 : 1
  length  = 32
  special = false
}

resource "random_password" "password" {
  length  = 32
  special = false
}

resource "kubernetes_manifest" "cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = local.name_prefix
      namespace = var.namespace
    }
    spec = {
      instances             = var.number_of_replicas
      primaryUpdateStrategy = "unsupervised"
      storage = {
        storageClass = "longhorn-postgres"
        size         = "${var.volume_size}Gi"
      }
      superuserSecret = {
        name = "${local.name_prefix}-superuser"
      }
      enableSuperuserAccess = true
      bootstrap = {
        initdb = {
          database = var.name
          owner    = var.name
          secret = {
            name = local.name_prefix
          }
        }
      }
      monitoring = {
        enablePodMonitor = true
      }
      backup = {
        barmanObjectStore = {
          endpointURL     = "https://s3.hl.${var.domain}/"
          destinationPath = "s3://${var.cluster_name}-postgres-backup/${var.namespace}/${var.name}"
          s3Credentials = {
            accessKeyId = {
              name = "${local.name_prefix}-minio-backup"
              key  = "access_key"
            }
            secretAccessKey = {
              name = "${local.name_prefix}-minio-backup"
              key  = "secret_access_key"
            }
          }
          data = {
            compression = "gzip"
          }
          wal = {
            compression = "gzip"
          }
        }
        retentionPolicy = "90d"
      }
      externalClusters = var.external_clusters
    }
  }
}

resource "kubernetes_manifest" "backup_schedule" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "ScheduledBackup"
    metadata = {
      name      = "${local.name_prefix}-backup"
      namespace = var.namespace
    }
    spec = {
      schedule = "@weekly"
      cluster = {
        name = "${var.name}-postgres"
      }
    }
  }

}

resource "kubernetes_secret_v1" "superuser" {
  metadata {
    name      = "${local.name_prefix}-superuser"
    namespace = var.namespace
  }
  data = {
    username = "postgres"
    password = var.is_superuser_password_same ? random_password.password.result : random_password.superuser[0].result
  }
  type = "kubernetes.io/basic-auth"
}

resource "kubernetes_secret_v1" "password" {
  metadata {
    name      = local.name_prefix
    namespace = var.namespace
  }
  data = {
    username = var.name
    password = random_password.password.result
  }
  type = "kubernetes.io/basic-auth"
}

resource "kubernetes_secret_v1" "minio" {
  metadata {
    name      = "${local.name_prefix}-minio-backup"
    namespace = var.namespace
  }
  data = {
    access_key = minio_iam_service_account.backup.access_key
    secret_access_key = minio_iam_service_account.backup.secret_key
  }
  type = "Opaque"
}
