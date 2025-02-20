
import {
    to = rancher2_cluster_v2.management
    id = "fleet-local/local"
}

resource "rancher2_cluster_v2" "management" {
  name = "local"
  kubernetes_version = "v1.31.5+k3s1"
  fleet_namespace = "fleet-local"
  rke_config {
    etcd {
      snapshot_schedule_cron = "0 */12 * * *"
      snapshot_retention = 10
      s3_config {
        bucket = minio_s3_bucket.management-etcd.bucket
        endpoint = "https://${data.infisical_secrets.bootstrap_secrets.secrets["minio_endpoint"].value}"
        cloud_credential_name = rancher2_cloud_credential.minio_etc_bucket.name
      }
    }
  }

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