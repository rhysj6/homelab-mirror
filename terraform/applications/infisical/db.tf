resource "random_password" "redis_password" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "redis_auth" {
  metadata {
    name      = "redis-auth"
    namespace = kubernetes_namespace.infisical.id
  }
  data = {
    password          = random_password.redis_password.result
    connection_string = "redis://:${random_password.redis_password.result}@redis-master.${kubernetes_namespace.infisical.id}:6379"
  }
}

resource "helm_release" "redis" {
  chart       = "redis"
  repository  = "https://charts.bitnami.com/bitnami"
  name        = "redis"
  namespace   = kubernetes_namespace.infisical.id
  version     = "22.0.7"
  max_history = 2
  values = [
    yamlencode({
      architecture = "standalone"
      cluster = {
        enabled = false
      }
      usePassword = true
      auth = {
        existingSecret            = "redis-auth"
        existingSecretPasswordKey = "password"
      }
      master = {
        nodeSelector = {
          storage_enabled = "true"
        }
      }
      global = {
        security = {
          allowInsecureImages = true
        }
      }
      image = {
        repository = "bitnamilegacy/redis"
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.infisical,
    kubernetes_secret.redis_auth,
  ]
}


resource "kubernetes_secret" "postgres_creds" {
  metadata {
    name      = "infisical-postgres-creds"
    namespace = kubernetes_namespace.infisical.id
  }
  data = {
    uri = "postgresql://${data.infisical_secrets.db_creds.secrets.INFISICAL_USERNAME.value}:${data.infisical_secrets.db_creds.secrets.INFISICAL_PASSWORD.value}@postgresql-rw.cnpg-system.svc.cluster.local/infisical"
  }
}
