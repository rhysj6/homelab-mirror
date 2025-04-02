resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"
  }
}

resource "helm_release" "longhorn" {
  chart       = "longhorn"
  repository  = "https://charts.longhorn.io"
  name        = "longhorn"
  namespace   = kubernetes_namespace.longhorn.id
  version     = "1.8.0"
  max_history = 2
  values = [
    yamlencode({
      defaultSettings = {
        orphanAutoDeletion                          = false
        autoDeletePodWhenVolumeDetachedUnexpectedly = true
        nodeDownPodDeletionPolicy                   = "delete-both-statefulset-and-deployment-pod"
        nodeDrainPolicy                             = "always-allow"
      }
      persistence = {
        defaultClassReplicaCount = var.number_of_nodes
      }
      backupTarget = {
        backupTarget = "s3://${minio_s3_bucket.longhorn_backup.bucket}@us-east-1/"
        backupTargetCredentialSecret = kubernetes_secret.longhorn_backup.metadata[0].name
      }
    })
  ]
}

resource "kubernetes_secret" "longhorn_backup" {
  metadata {
    name      = "longhorn-minio-backup"
    namespace = kubernetes_namespace.longhorn.id
  }
  data = {
    "AWS_ACCESS_KEY_ID"     = minio_iam_service_account.longhorn_backup.access_key
    "AWS_SECRET_ACCESS_KEY" = minio_iam_service_account.longhorn_backup.secret_key
    "AWS_ENDPOINTS"         = "https://${data.infisical_secrets.bootstrap.secrets["minio_endpoint"].value}/"
  }
  type = "Opaque"
}

resource "minio_s3_bucket" "longhorn_backup" {
  bucket = "${var.cluster_name}-longhorn-backup"
  acl    = "private"
}


resource "minio_ilm_policy" "longhorn_backup" {
  bucket = minio_s3_bucket.longhorn_backup.bucket

  rule {
    id     = "versioning"
    noncurrent_expiration {
      days           = "15d" ## 15 days since chances of data loss that isn't found in 15 days is very low
    }
    expiration = "DeleteMarker"
  }
}

resource "minio_iam_policy" "longhorn_backup" {
  name = "${var.cluster_name}-longhorn-backup-full-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${minio_s3_bucket.longhorn_backup.bucket}/*"]
      }
    ]
  })
}

resource "minio_iam_user" "longhorn_backup" {
  name = "${var.cluster_name}-longhorn-backup"
}

resource "minio_iam_user_policy_attachment" "longhorn_backup" {
  user_name   = minio_iam_user.longhorn_backup.name
  policy_name = minio_iam_policy.longhorn_backup.name
}

resource "minio_iam_service_account" "longhorn_backup" {
  target_user = minio_iam_user.longhorn_backup.name
}
