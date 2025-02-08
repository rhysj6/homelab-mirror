locals {
  terrakube_hostname = "tf.hl.${local.domain}"
}

## Create a Minio bucket for Terrakube with applicable IAM policies

resource "minio_s3_bucket" "terrakube" {
  bucket = "terrakube"
  acl    = "private"
}

resource "minio_s3_bucket_versioning" "terrakube" {
  depends_on = [minio_s3_bucket.terrakube]
  bucket     = minio_s3_bucket.terrakube.bucket

  versioning_configuration {
    status = "Enabled"
  }
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
  name               = "terrakube"
  client_id          = "terrakube"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.authentik_host.id
  redirect_uris = [
    "https://api.${local.terrakube_hostname}/dex/callback",
  ]
  property_mappings = [
    "fa7e62f8-1719-40b5-8352-3a675aef2b07", # data.authentik_property_mapping_provider_scope.scope-email.id,
    "c02d98e6-3ec2-4d2c-8d98-1a03b21f5ebc", # data.authentik_property_mapping_provider_scope.scope-openid.id,
    "7df79a96-9f18-4451-9faa-0a879302efd6" # data.authentik_property_mapping_provider_scope.scope-profile.id,
  ]
}

resource "authentik_application" "terrakube" {
  name              = "Terrakube"
  slug              = "terrakube"
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
    value = "https://${var.authentik_host}/application/o/${authentik_application.terrakube.id}/"
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
    name  = "dex.config.staticClients[0].redirectURIs"
    value = ["https://api.${local.terrakube_hostname}/dex", "https://${local.terrakube_hostname}"]
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
    value = data.infisical_secrets.bootstrap_secrets.secrets["minio_endpoint"].value
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

