locals {
  terrakube_hostname = "tf.hl.${local.domain}"
}

## Create a Minio bucket for Terrakube with applicable IAM policies
resource "minio_s3_bucket" "terrakube" {
  bucket = "terrakube"
  acl    = "private"
}

resource "minio_iam_policy" "terrakube" {
  name = "terrakube-full-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${minio_s3_bucket.terrakube.bucket}/*"]
      }
    ]
  })
}

resource "minio_iam_user" "terrakube" {
  name = "terrakube"
}

resource "minio_iam_user_policy_attachment" "terrakube" {
  user_name   = minio_iam_user.terrakube.name
  policy_name = minio_iam_policy.terrakube.name
}

resource "minio_iam_service_account" "terrakube" {
  target_user = minio_iam_user.terrakube.name
}

## Create the authentik authentication provider and application and an admin group

resource "authentik_provider_oauth2" "terrakube" {
  name               = "Terrakube - (Managed via Terraform)"
  client_id          = "terrakube"
  authorization_flow = data.authentik_flow.authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.domain.id
  allowed_redirect_uris = [
    {
      url           = "https://api.${local.terrakube_hostname}/dex/callback"
      matching_mode = "strict"
    }
  ]
  authentication_flow = data.authentik_flow.authorization-flow.id
  invalidation_flow   = data.authentik_flow.invalidation-flow.id
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
  ]
}

resource "authentik_application" "terrakube" {
  name              = "Terrakube"
  slug              = "terrakube"
  group             = "Infrastructure"
  meta_launch_url   = "https://${local.terrakube_hostname}"
  open_in_new_tab   = true
  protocol_provider = authentik_provider_oauth2.terrakube.id
}

resource "authentik_group" "terrakube_admins" {
  name = "TERRAKUBE_ADMIN"
}

## Generate random passwords for Redis and PostgreSQL

resource "random_password" "terrakube_redis_password" {
  length  = 16
  special = false
}

resource "random_password" "terrakube_postgresql_password" {
  length  = 16
  special = false
}

## Create the Terrakube Helm release

resource "helm_release" "terrakube" {
  name             = "terrakube"
  repository       = "https://azbuilder.github.io/terrakube-helm-chart"
  chart            = "terrakube"
  version          = "3.24.0"
  namespace        = "terrakube"
  create_namespace = true
  values = [
    "${file("terrakube_values.yaml")}"
  ]

  ## Override the authentik provider and application IDs.
  set {
    name  = "dex.config.issuer"
    value = "https://api.${local.terrakube_hostname}/dex"
  }
  set {
    name  = "dex.config.connectors[0].config.issuer"
    value = "https://${local.authentik_host}/application/o/${authentik_application.terrakube.id}/"
  }
  set {
    name  = "dex.config.connectors[0].config.clientSecret"
    value = authentik_provider_oauth2.terrakube.client_secret
  }
  set {
    name  = "dex.config.connectors[0].config.redirectURI"
    value = "https://api.${local.terrakube_hostname}/dex/callback"
  }
  set_list {
    name = "dex.config.staticClients[0].redirectURIs"
    value = [
      "https://api.${local.terrakube_hostname}/dex",
      "https://${local.terrakube_hostname}",
      "/device/callback",
      "http://localhost:10000/login",
      "http://localhost:10001/login"
    ]
  }

  ## Set the random Redis and PostgreSQL passwords.
  set {
    name  = "redis.auth.password"
    value = random_password.terrakube_redis_password.result
  }
  set {
    name  = "postgresql.auth.password"
    value = random_password.terrakube_postgresql_password.result
  }

  ## Set the Minio bucket and IAM user credentials.
  set {
    name  = "storage.minio.bucketName"
    value = minio_s3_bucket.terrakube.bucket
  }
  set {
    name  = "storage.minio.accessKey"
    value = minio_iam_service_account.terrakube.access_key
  }
  set {
    name  = "storage.minio.secretKey"
    value = minio_iam_service_account.terrakube.secret_key
  }
  set {
    name  = "storage.minio.endpoint"
    value = "https://${data.infisical_secrets.bootstrap_secrets.secrets["minio_endpoint"].value}"
  }

  ## Set the domains for the Terrakube application.
  set {
    name  = "ingress.ui.domain"
    value = local.terrakube_hostname
  }
  set {
    name  = "ingress.api.domain"
    value = "api.${local.terrakube_hostname}"
  }
  set {
    name  = "ingress.registry.domain"
    value = "registry.${local.terrakube_hostname}"
  }
}

# Cluster role binding for the Terrakube service account
resource "kubernetes_cluster_role_binding" "terrakube" {
  depends_on = [helm_release.terrakube]
  metadata {
    name = "terrakube"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = helm_release.terrakube.namespace
  }
}
