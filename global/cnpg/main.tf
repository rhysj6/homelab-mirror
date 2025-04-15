
resource "minio_s3_bucket" "postgresql_backup" {
  bucket = "postgresql-backup"
  acl    = "private"
}

resource "minio_iam_policy" "postgresql_backup" {
  name = "postgresql-backup-full-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${minio_s3_bucket.postgresql_backup.bucket}/*"]
      }
    ]
  })
}

resource "minio_ilm_policy" "postgresql_backup" {
  bucket = minio_s3_bucket.postgresql_backup.bucket

  rule {
    id     = "versioning"
    noncurrent_expiration {
      days           = "45d"
    }
    expiration = "DeleteMarker"
  }
}
resource "minio_iam_user" "postgresql_backup" {
  name = "postgresql-backup"
}

resource "minio_iam_user_policy_attachment" "postgresql_backup" {
  user_name   = minio_iam_user.postgresql_backup.name
  policy_name = minio_iam_policy.postgresql_backup.name
}
