locals {
  semaphore_hostname     = "iac.hl.${local.domain}"
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

## Create the semaphore application
resource "kubernetes_persistent_volume_claim" "semaphore_boltdb" {
  metadata {
    name      = "semaphore-boltdb"
    namespace = kubernetes_namespace.semaphore.id
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}
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
          provider_url   = "https://${local.authentik_host}/application/o/${authentik_application.semaphore.id}/"
          client_id      = authentik_provider_oauth2.semaphore.client_id
          client_secret  = authentik_provider_oauth2.semaphore.client_secret
          redirect_url   = local.semaphore_redirect_url
          scopes         = ["openid", "profile", "email"]
          username_claim = "preferred_username"
          name_claim     = "preferred_username"
        }
      }
    })
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
        service_account_name = kubernetes_service_account.semaphore.metadata.0.name
        security_context {
          fs_group = 1001
        }
        container {
          name  = "semaphore"
          image = "semaphoreui/semaphore:v2.12.14"
          env {
            name  = "SEMAPHORE_DB_DIALECT"
            value = "bolt"
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
            name       = "boltdb"
            mount_path = "/var/lib/semaphore"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.semaphore.metadata.0.name
          }
        }
        volume {
          name = "boltdb"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.semaphore_boltdb.metadata.0.name
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
              name = kubernetes_service.semaphore.metadata.0.name
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
