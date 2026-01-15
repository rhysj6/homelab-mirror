locals {
  url = "technitium.hl.${data.infisical_secrets.common.secrets.domain.value}"
}

resource "kubernetes_namespace" "dns" {
  metadata {
    name = "dns"
  }
}

resource "kubernetes_persistent_volume_claim" "technitium" {
  metadata {
    name      = "technitium"
    namespace = kubernetes_namespace.dns.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "technitium" {
  metadata {
    name      = "technitium"
    namespace = kubernetes_namespace.dns.metadata[0].name
    labels = {
      app = "technitium"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "technitium"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = "technitium"
        }
      }
      spec {
        container {
          name  = "technitium"
          image = "technitium/dns-server:14.3.0"
          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.technitium_config.metadata[0].name
            }
          }
          env {
            name = "DNS_SERVER_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.password.metadata[0].name
                key  = "password"
              }
            }
          }
          volume_mount {
            name       = "stateful-storage"
            mount_path = "/etc/dns"
          }
          port {
            container_port = 5380
            name           = "http"
          }
          port {
            container_port = 53
            protocol       = "UDP"
            name           = "dns-udp"
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 5380
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 5380
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
        node_selector = {
          "storage_enabled" = "true"
        }
        volume {
          name = "stateful-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.technitium.metadata[0].name
          }
        }
      }
    }
  }
}

// Dns service
resource "kubernetes_service_v1" "technitium_lb" {
  metadata {
    name      = "technitium-lb"
    namespace = kubernetes_namespace.dns.metadata[0].name
    labels = {
      app = "technitium"
    }
    annotations = {
      "lbipam.cilium.io/ips" = var.loadbalancer_ip
    }
  }
  spec {
    selector = {
      app = "technitium"
    }
    type = "LoadBalancer"
    port {
      port        = 53
      target_port = 53
      protocol    = "UDP"
      name        = "dns-udp"
    }
    port {
      port        = 5380
      target_port = 5380
      protocol    = "TCP"
      name        = "http"
    }
    external_traffic_policy = "Local"
  }
}
