## Create a Minio bucket for etcd with applicable IAM policies
resource "minio_s3_bucket" "etcd" {
  bucket = "${var.cluster_name}-cluster-etcd"
  acl    = "private"
}

resource "minio_iam_policy" "etcd" {
  name = "${var.cluster_name}-etcd-full-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${minio_s3_bucket.etcd.bucket}/*"]
      }
    ]
  })
}

resource "minio_iam_user" "etcd" {
  name = "${var.cluster_name}-etcd"
}

resource "minio_iam_user_policy_attachment" "etcd" {
  user_name   = minio_iam_user.etcd.name
  policy_name = minio_iam_policy.etcd.name
}

resource "minio_iam_service_account" "etcd" {
  target_user = minio_iam_user.etcd.name
}

resource "minio_ilm_policy" "bucket-lifecycle-rules" {
  bucket = minio_s3_bucket.etcd.bucket

  rule {
    id = "versioning"
    noncurrent_expiration {
      days = "45d"
    }
    expiration = "DeleteMarker"
  }
}