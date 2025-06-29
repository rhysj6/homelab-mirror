resource "kubernetes_namespace" "cattle_resources_system" {
  metadata {
    name = "cattle-resources-system"
  }
}

resource "kubernetes_secret" "rancher_backup" {
  metadata {
    name      = "rancher-minio-backup"
    namespace = kubernetes_namespace.cattle_resources_system.id
  }
  data = {
    accessKey = minio_iam_service_account.rancher_backup.access_key
    secretKey = minio_iam_service_account.rancher_backup.secret_key
  }
  type = "Opaque"
}

resource "minio_s3_bucket" "rancher_backup" {
  bucket = "rancher"
  acl    = "private"
}

resource "minio_ilm_policy" "rancher_backup" {
  bucket = minio_s3_bucket.rancher_backup.bucket
  rule {
    id = "versioning"
    noncurrent_expiration {
      days = "15d" ## 15 days since chances of data loss that isn't found in 15 days is very low
    }
    expiration = "DeleteMarker"
  }
}

resource "minio_iam_policy" "rancher_backup" {
  name = "rancher-backup-full-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${minio_s3_bucket.rancher_backup.bucket}/*"]
      }
    ]
  })
}

resource "minio_iam_user" "rancher_backup" {
  name = "rancher-backup"
}

resource "minio_iam_user_policy_attachment" "rancher_backup" {
  user_name   = minio_iam_user.rancher_backup.name
  policy_name = minio_iam_policy.rancher_backup.name
}

resource "minio_iam_service_account" "rancher_backup" {
  target_user = minio_iam_user.rancher_backup.name
}

resource "helm_release" "backups_crd" {
  name       = "rancher-backup-crd"
  repository = "https://charts.rancher.io"
  chart      = "rancher-backup-crd"
  namespace  = kubernetes_namespace.cattle_resources_system.metadata[0].name
}

resource "helm_release" "backups" {
  name       = "rancher-backup"
  repository = "https://charts.rancher.io"
  chart      = "rancher-backup"
  namespace  = kubernetes_namespace.cattle_resources_system.metadata[0].name
  depends_on = [helm_release.backups_crd]
  set = [
    {
      name  = "s3.enabled"
      value = "true"
    },
    {
      name  = "s3.endpoint"
      value = "s3.hl.${var.domain}"
    },
    {
      name  = "s3.bucketName"
      value = minio_s3_bucket.rancher_backup.bucket
    },
    {
      name  = "s3.credentialSecretName"
      value = kubernetes_secret.rancher_backup.metadata[0].name
    },
    {
      name  = "s3.credentialSecretNamespace"
      value = kubernetes_namespace.cattle_resources_system.metadata[0].name
    }
  ]
}

resource "kubernetes_manifest" "backup" {
  manifest = {
    apiVersion = "resources.cattle.io/v1"
    kind       = "Backup"
    metadata = {
      name = "rancher-minio-backup"
    }
    spec = {
      resourceSetName = "rancher-resource-set-full"
      schedule        = "@every 12h"
      retentionCount  = 10
    }
  }

  depends_on = [helm_release.backups_crd] # If the CRD is not created then this plan will fail, run the plan with -target=helm_release.backups_crd
}
