data "rancher2_cluster_v2" "management" {
  name = "local"
  fleet_namespace = "fleet-local"
}

# Create a new rancher2 Etcd Backup
resource "rancher2_etcd_backup" "backup" {
  backup_config {
    enabled = true
    interval_hours = 12
    retention = 10
    s3_backup_config {
      access_key = minio_iam_service_account.management-etcd.access_key
      bucket_name = minio_s3_bucket.management-etcd.bucket
      endpoint = "https://${data.infisical_secrets.bootstrap_secrets.secrets["minio_endpoint"].value}"
      secret_key = minio_iam_service_account.management-etcd.secret_key
    }
  }
  cluster_id = data.rancher2_cluster_v2.management.cluster_v1_id
  name = "backup"
}

## Create a Minio bucket for management-etcd with applicable IAM policies
resource "minio_s3_bucket" "management-etcd" {
  bucket = "management-cluster-etcd"
  acl    = "private"
}

resource "minio_iam_policy" "management-etcd" {
  name = "management-etcd-full-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${minio_s3_bucket.management-etcd.bucket}/*"]
      }
    ]
  })
}

resource "minio_iam_user" "management-etcd" {
  name = "management-etcd"
}

resource "minio_iam_user_policy_attachment" "management-etcd" {
  user_name   = minio_iam_user.management-etcd.name
  policy_name = minio_iam_policy.management-etcd.name
}

resource "minio_iam_service_account" "management-etcd" {
  target_user = minio_iam_user.management-etcd.name
}

resource "rancher2_cloud_credential" "minio_etc_bucket" {
  name = "minio-etc-bucket"
  s3_credential_config {
    access_key = minio_iam_service_account.management-etcd.access_key
    secret_key = minio_iam_service_account.management-etcd.secret_key
  }
}