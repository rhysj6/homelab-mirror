locals {
  semaphore_hostname     = "iac.hl.${var.domain}"
  semaphore_redirect_url = "https://${local.semaphore_hostname}/api/auth/oidc/authentik/redirect/"
}

## Create the authentik authentication provider and application and an admin group
resource "authentik_provider_oauth2" "semaphore" {
  name               = "Semaphore - (Managed via Terraform)"
  client_id          = "semaphore"
  authorization_flow = data.authentik_flow.authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.domain.id
  allowed_redirect_uris = [{
    url           = local.semaphore_redirect_url
    matching_mode = "strict"
  }]
  authentication_flow = data.authentik_flow.authorization-flow.id
  invalidation_flow   = data.authentik_flow.invalidation-flow.id
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
  ]
}

resource "authentik_application" "semaphore" {
  name              = "Semaphore"
  slug              = "semaphore"
  group             = "Infrastructure"
  meta_launch_url   = "https://${local.semaphore_hostname}"
  open_in_new_tab   = true
  protocol_provider = authentik_provider_oauth2.semaphore.id
}

# Create the Semaphore namespace
resource "kubernetes_namespace" "semaphore" {
  metadata {
    name = "semaphore"
  }
}

module "postgresql" {
  source                     = "../../../modules/postgres_cluster"
  namespace                  = kubernetes_namespace.semaphore.id
  name                       = "semaphore"
  cluster_name               = "management"
  is_superuser_password_same = true
  volume_size                = 10
  domain = var.domain
}

## Create the semaphore application
resource "kubernetes_service_account" "semaphore" {
  metadata {
    name      = "semaphore"
    namespace = kubernetes_namespace.semaphore.id
  }
}

resource "kubernetes_config_map" "semaphore" {
  metadata {
    name      = "semaphore"
    namespace = kubernetes_namespace.semaphore.id
  }
  data = {
    "config.json" = jsonencode({
      oidc_providers = {
        authentik = {
          display_name   = "Sign in with Authentik"
          provider_url   = "https://hl.${var.domain}/application/o/${authentik_application.semaphore.id}/"
          client_id      = authentik_provider_oauth2.semaphore.client_id
          client_secret  = authentik_provider_oauth2.semaphore.client_secret
          redirect_url   = local.semaphore_redirect_url
          scopes         = ["openid", "profile", "email"]
          username_claim = "preferred_username"
          name_claim     = "preferred_username"
        }
      }
    })
    "requirements.txt" = <<EOF
      passlib
      EOF
  }
}

resource "random_password" "semaphore_cookie_hash" {
  length  = 64
  special = false
}

resource "kubernetes_deployment" "semaphore" {
  metadata {
    name      = "semaphore"
    namespace = kubernetes_namespace.semaphore.id
  }
  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "semaphore"
      }
    }
    template {
      metadata {
        labels = {
          app = "semaphore"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.semaphore.metadata[0].name
        container {
          name  = "semaphore"
          image = "semaphoreui/semaphore:v2.15.0"
          env {
            name  = "SEMAPHORE_DB_DIALECT"
            value = "postgres"
          }
          env {
            name = "SEMAPHORE_DB_HOST"
            value_from {
              secret_key_ref {
                name = module.postgresql.secret_name
                key  = "host"
              }
            }
          }
          env {
            name = "SEMAPHORE_DB_USER"
            value_from {
              secret_key_ref {
                name = module.postgresql.secret_name
                key  = "username"
              }
            }
          }
          env {
            name = "SEMAPHORE_DB_PASS"
            value_from {
              secret_key_ref {
                name = module.postgresql.secret_name
                key  = "password"
              }
            }
          }
          env {
            name = "SEMAPHORE_DB_NAME"
            value_from {
              secret_key_ref {
                name = module.postgresql.secret_name
                key  = "dbname"
              }
            }
          }
          env {
            name  = "SEMAPHORE_PASSWORD_LOGIN_DISABLED"
            value = true
          }
          env {
            name  = "SEMAPHORE_PORT"
            value = 3000
          }
          env {
            name  = "SEMAPHORE_WEB_ROOT"
            value = "https://${local.semaphore_hostname}/"
          }
          env {
            name  = "SEMAPHORE_COOKIE_HASH"
            value = random_password.semaphore_cookie_hash.result
          }
          port {
            name           = "http"
            container_port = 3000
            protocol       = "TCP"
          }
          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }
          }
          readiness_probe {
            http_get {
              path = "/"
              port = "http"
            }
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/semaphore/config.json"
            sub_path   = "config.json"
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/semaphore/requirements.txt"
            sub_path   = "requirements.txt"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.semaphore.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "semaphore" {
  metadata {
    name      = "semaphore"
    namespace = kubernetes_namespace.semaphore.id
  }
  spec {
    selector = {
      app = "semaphore"
    }
    port {
      name        = "http"
      port        = 3000
      target_port = "http"
    }
  }
}

resource "kubernetes_ingress_v1" "semaphore" {
  metadata {
    name      = "semaphore"
    namespace = kubernetes_namespace.semaphore.id
    annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager"
    }
  }
  spec {
    rule {
      host = local.semaphore_hostname
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.semaphore.metadata[0].name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = [local.semaphore_hostname]
      secret_name = "semaphore-tls"
    }
  }
}
