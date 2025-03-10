
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
      name      = "${var.name}-postgres"
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
        name = "${var.secret_name}-superuser"
      }
      enableSuperuserAccess = true
      bootstrap = {
        initdb = {
          database = var.name
          owner    = var.name
          secret = {
            name = var.secret_name
          }
        }
      }
      backup = {
        barmanObjectStore = {
          endpointURL     = "https://${data.infisical_secrets.bootstrap.secrets["minio_endpoint"].value}/"
          destinationPath = "s3://${var.cluster_name}-postgres-backup/${var.namespace}/${var.name}"
          s3Credentials = {
            accessKeyId = {
              name = "minio-postgres-backup"
              key  = "access_key"
            }
            secretAccessKey = {
              name = "minio-postgres-backup"
              key  = "secret_key"
            }
          }
          data = {
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
      name      = "${var.name}-postgres-backup"
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
    name      = "${var.secret_name}-superuser"
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
    name      = var.secret_name
    namespace = var.namespace
  }
  data = {
    username = "postgres"
    password = random_password.password.result
  }
  type = "kubernetes.io/basic-auth"
}

resource "kubernetes_secret_v1" "minio" {
  metadata {
    name      = "minio-postgres-backup"
    namespace = var.namespace
  }
  data = {
    access_key = minio_iam_service_account.backup.access_key
    secret_key = minio_iam_service_account.backup.secret_key
  }
  type = "Opaque"
}
