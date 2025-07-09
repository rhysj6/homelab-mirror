locals {
  loki_url = "loki.hl.${var.domain}"
  loki_buckets = [
    "chunks",
    "ruler",
    "admin"
  ]
  loki_bucket_prefix = "loki"
}

resource "random_integer" "loki_password_length" {
  min = 16
  max = 64
}
resource "random_password" "loki_password" {
  length  = random_integer.loki_password_length.result // This is done because the repo is public and we don't want to expose the password length
  special = false
}

resource "helm_release" "loki" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  name       = "loki"
  namespace  = "monitoring"
  version    = "6.31.0"
  values = [
    templatefile("${path.module}/templates/loki_values.yaml", {
      BUCKET_PREFIX        = local.loki_bucket_prefix
      S3_ENDPOINT          = "s3.hl.${var.domain}"
      S3_SECRET_ACCESS_KEY = minio_iam_service_account.loki.secret_key
      S3_ACCESS_KEY_ID     = minio_iam_service_account.loki.access_key
      INGRESS_HOST         = local.loki_url
      BASIC_AUTH_PASSWORD  = random_password.loki_password.result
    })
  ]
  depends_on = [
    minio_iam_service_account.loki,
    minio_iam_user_policy_attachment.loki,
    minio_iam_user.loki,
    minio_s3_bucket.loki
  ]
}

# Loki minio Buckets
resource "minio_s3_bucket" "loki" {
  for_each = toset(local.loki_buckets)
  bucket   = "${local.loki_bucket_prefix}-${each.key}"
  acl      = "private"
}

resource "minio_ilm_policy" "loki" {
  for_each = toset(local.loki_buckets)
  bucket   = "${local.loki_bucket_prefix}-${each.key}"
  rule {
    id = "versioning"
    noncurrent_expiration {
      days = "45d"
    }
    expiration = "DeleteMarker"
  }
  depends_on = [
    minio_s3_bucket.loki
  ]
}

resource "minio_iam_policy" "loki" {
  name = "loki-full-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:*"]
        Effect = "Allow"
        Resource = flatten([
          for bucket in local.loki_buckets : [
            "arn:aws:s3:::${local.loki_bucket_prefix}-${bucket}",
            "arn:aws:s3:::${local.loki_bucket_prefix}-${bucket}/*"
          ]
        ])
      }
    ]
  })
  depends_on = [
    minio_s3_bucket.loki
  ]
}

resource "minio_iam_user" "loki" {
  name = "loki"
}

resource "minio_iam_user_policy_attachment" "loki" {
  user_name   = minio_iam_user.loki.name
  policy_name = minio_iam_policy.loki.name
}

resource "minio_iam_service_account" "loki" {
  target_user = minio_iam_user.loki.name
}
