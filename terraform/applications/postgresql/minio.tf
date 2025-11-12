resource "minio_s3_bucket" "postgres_backup" {
  bucket = "${var.env}-postgresql-backup"
  acl    = "private"
}

resource "minio_iam_policy" "postgres_backup" {
  name = "${var.env}-postgresql-backup-full-access-policy"
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
    id = "versioning"
    noncurrent_expiration {
      days = "45d"
    }
    expiration = "DeleteMarker"
  }
}

resource "minio_iam_user" "postgres_backup" {
  name = "${var.env}-postgresql-backup"
}

resource "minio_iam_user_policy_attachment" "postgres_backup" {
  user_name   = minio_iam_user.postgres_backup.name
  policy_name = minio_iam_policy.postgres_backup.name
}

resource "minio_iam_service_account" "backup" {
  target_user = minio_iam_user.postgres_backup.name
}

resource "kubernetes_secret_v1" "minio" {
  metadata {
    name      = "minio-backup"
    namespace = "cnpg-system"
  }
  data = {
    access_key        = minio_iam_service_account.backup.access_key
    secret_access_key = minio_iam_service_account.backup.secret_key
  }
  type = "Opaque"
}
