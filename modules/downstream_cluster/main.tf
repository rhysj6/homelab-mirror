# resource "kubernetes_manifest" "cluster" {
#   count = var.firstrun ? 0 : 1
#   manifest = yamldecode(templatefile("${path.module}/templates/cluster.yaml", {
#     cluster_name          = var.cluster_name,
#     kubernetes_version    = "v1.31.5+rke2r1",
#     bucket_name           = minio_s3_bucket.etcd.bucket,
#     cloud_credential_name = rancher2_cloud_credential.minio_etc_bucket.id,
#     s3_endpoint           = "https://${data.infisical_secrets.bootstrap_secrets.secrets["minio_endpoint"].value}"
#   }))
# }

resource "rancher2_cluster_v2" "cluster" {
  name               = var.cluster_name
  kubernetes_version = "v1.31.5+rke2r1"
  fleet_namespace    = "fleet-default"
  rke_config {
    etcd {
      snapshot_schedule_cron = "0 */5 * * *"
      snapshot_retention     = 5
      s3_config {
        endpoint              = "https://${data.infisical_secrets.bootstrap_secrets.secrets["minio_endpoint"].value}"
        bucket                = minio_s3_bucket.etcd.bucket
        cloud_credential_name = rancher2_cloud_credential.minio_etc_bucket.id
      }
    }
    chart_values = yamlencode({
      rke2-cilium = {
        kubeProxyReplacement = true
        k8sServiceHost       = "localhost"
        k8sServicePort       = 6443
        externalIPs = {
          enabled = true
        }
        l2announcements = {
          enabled = true
        }
        k8sClientRateLimit = {
          burst = 128
          qps   = 64
        }
        ipam = {
          operator = {
            clusterPoolIPv4PodCIDRList = [
              "10.42.0.0/16"
            ]
          }
        }
      }
    })
    machine_global_config = yamlencode({
      cni = "cilium"
      disable = [
        "rke2-ingress-nginx"
      ]
      disable-kube-proxy = true
    })
    machine_selector_config {
      config = yamlencode({
        profile = "cis"
        protect-kernel-defaults = true
      })
    }
  }
}


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

resource "rancher2_cloud_credential" "minio_etc_bucket" {
  name = "${var.cluster_name}-minio-etc-bucket"
  s3_credential_config {
    access_key = minio_iam_service_account.etcd.access_key
    secret_key = minio_iam_service_account.etcd.secret_key
  }
}
