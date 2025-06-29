resource "kubernetes_manifest" "longhorn_postgres" {
  manifest = {
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "longhorn-postgres"
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

resource "helm_release" "cloud_native_postgres" {
  chart       = "cloudnative-pg"
  repository  = "https://cloudnative-pg.github.io/charts"
  name        = "cloud-native-postgres"
  namespace   = "cnpg-system"
  create_namespace = true
  version     = "0.24.0"
  max_history = 2
}

resource "minio_s3_bucket" "postgres_backup" {
  bucket = "${var.cluster_name}-postgres-backup"
  acl    = "private"
}

resource "minio_iam_policy" "postgres_backup" {
  name = "${var.cluster_name}-postgres-backup-full-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${minio_s3_bucket.postgres_backup.bucket}/*"]
      }
    ]
  })
}

resource "minio_ilm_policy" "postgres_backup" {
  bucket = minio_s3_bucket.postgres_backup.bucket

  rule {
    id     = "versioning"
    noncurrent_expiration {
      days           = "45d"
    }
    expiration = "DeleteMarker"
  }
}
resource "minio_iam_user" "postgres_backup" {
  name = "${var.cluster_name}-postgres-backup"
}

resource "minio_iam_user_policy_attachment" "postgres_backup" {
  user_name   = minio_iam_user.postgres_backup.name
  policy_name = minio_iam_policy.postgres_backup.name
}
