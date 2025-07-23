
module "postgresql" {
  source                     = "../../../modules/postgres_cluster"
  namespace                  = kubernetes_namespace.infisical.id
  name                       = "infisical"
  cluster_name               = "management"
  volume_size                = 10
  domain = var.domain
}

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
    password = random_password.redis_password.result
    connection_string = "redis://:${random_password.redis_password.result}@redis-master.${kubernetes_namespace.infisical.id}:6379"
  }
}

resource "helm_release" "redis" {
    chart       = "redis"
    repository  = "https://charts.bitnami.com/bitnami"
    name        = "redis"
    namespace   = kubernetes_namespace.infisical.id
    version     = "21.2.13"
    max_history = 2
    values = [
        yamlencode({
            architecture = "standalone"
            cluster = {
                enabled = false
            }
            usePassword = true
            auth = {
                existingSecret = "redis-auth"
                existingSecretPasswordKey = "password"
            }
        })
    ]

    depends_on = [
        kubernetes_namespace.infisical,
        kubernetes_secret.redis_auth,
    ]
}
