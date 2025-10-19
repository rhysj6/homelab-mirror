locals {
  name_prefix = "postgresql"
}

resource "kubernetes_manifest" "cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = local.name_prefix
      namespace = "cnpg-system"
    }
    spec = {
      instances             = 2
      primaryUpdateStrategy = "unsupervised"
      storage = {
        storageClass = "longhorn-postgresql"
        size         = "10Gi"
      }
      walStorage = {
        size         = "5Gi"
        storageClass = "longhorn-postgresql"
      }
      superuserSecret = {
        name = "postgresql-superuser"
      }
      enableSuperuserAccess = true
      bootstrap = {
      }
      monitoring = {
        enablePodMonitor = true
      }
      backup = {
        barmanObjectStore = {
          endpointURL     = "https://s3.hl.${var.domain}/"
          destinationPath = "s3://postgresql-backup"
          s3Credentials = {
            accessKeyId = {
              name = "minio-backup"
              key  = "access_key"
            }
            secretAccessKey = {
              name = "minio-backup"
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
    }
  }
}

resource "kubernetes_manifest" "backup_schedule" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "ScheduledBackup"
    metadata = {
      name      = "postgresql-backup"
      namespace = "cnpg-system"
    }
    spec = {
      schedule = "@daily"
      cluster = {
        name = "postgresql"
      }
    }
  }

}

