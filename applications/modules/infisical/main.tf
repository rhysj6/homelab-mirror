locals {
  infisical_hostname     = "secrets.hl.${var.domain}"
}

resource "kubernetes_namespace" "infisical" {
  metadata {
    name = "infisical"
  }
}

resource "kubernetes_service_account" "infisical" {
  metadata {
    name      = "infisical"
    namespace = kubernetes_namespace.infisical.id
  }
}

resource "random_password" "auth_secret" {
  length  = 16
}

resource "random_password" "encryption_key" {
  length  = 32
}

resource "kubernetes_secret" "infisical_secrets" {
  metadata {
    name      = "infisical-secrets"
    namespace = kubernetes_namespace.infisical.id
  }
  data = {
    AUTH_SECRET       = random_password.auth_secret.result
    ENCRYPTION_KEY    = random_password.encryption_key.result
    SITE_URL          = "https://${local.infisical_hostname}"
  }
}


resource "kubernetes_deployment" "infisical" {
  metadata {
    name      = "infisical"
    namespace = kubernetes_namespace.infisical.id
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "infisical"
      }
    }
    template {
      metadata {
        labels = {
          app = "infisical"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.infisical.metadata[0].name
        init_container {
          name  = "migration"
          image = "infisical/infisical:v0.146.0-postgres"
          command = ["npm", "run", "migration:latest"]
          env {
            name = "DB_CONNECTION_URI"
            value_from {
              secret_key_ref {
                name = module.postgresql.secret_name
                key  = "uri"
              }
            }
          }
          env {
            name = "ALLOW_INTERNAL_IP_CONNECTIONS"
            value = "true"
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.infisical_secrets.metadata[0].name
            }
          }
        }

        container {
          name  = "infisical"
          image = "infisical/infisical:v0.146.0-postgres"
          env {
            name = "DB_CONNECTION_URI"
            value_from {
              secret_key_ref {
                name = module.postgresql.secret_name
                key  = "uri"
              }
            }
          }
          env {
            name  = "REDIS_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redis_auth.metadata[0].name
                key  = "connection_string"
              }
            }
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.infisical_secrets.metadata[0].name
            }
          }

          readiness_probe {
            http_get {
              path = "/api/status"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds         = 5
          }
          port {
            name = "http"
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "infisical" {
  metadata {
    name      = "infisical"
    namespace = kubernetes_namespace.infisical.id
  }
  spec {
    selector = {
      app = "infisical"
    }
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }
  }
}

resource "kubernetes_ingress_v1" "infisical" {
  metadata {
    name      = "infisical"
    namespace = kubernetes_namespace.infisical.id
    annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager"
    }
  }
  spec {
    rule {
      host = local.infisical_hostname
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.infisical.metadata[0].name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = [local.infisical_hostname]
      secret_name = "infisical-tls"
    }
  }
}
