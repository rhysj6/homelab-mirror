locals {
  url = "pihole.hl.${var.domain}"
}

resource "kubernetes_namespace" "dns" {
  metadata {
    name = "dns"
  }
}

resource "random_password" "api_password" {
  length  = 32
  special = false
}


resource "kubernetes_secret_v1" "password" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.dns.metadata[0].name
  }
  data = {
    password = random_password.api_password.result
  }
  type = "Opaque"
}

resource "kubernetes_persistent_volume_claim" "pihole" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.dns.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "4Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "pihole" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.dns.metadata[0].name
    labels = {
      app = "pihole"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "pihole"
      }
    }
    template {
      metadata {
        labels = {
          app = "pihole"
        }
      }
      spec {
        container {
          name  = "pihole"
          image = "pihole/pihole:2024.07.0"
          env {
            name  = "TZ"
            value = "Europe/London"
          }
          env {
            name = "WEBPASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.password.metadata[0].name
                key  = "password"
              }
            }
          }
          volume_mount {
            name       = "pihole-storage"
            mount_path = "/etc/pihole"
          }
          port {
            container_port = 80
            name           = "http"
          }
          port {
            container_port = 53
            protocol       = "UDP"
            name           = "dns-udp"
          }
        }
        volume {
          name = "pihole-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pihole.metadata[0].name
          }
        }
      }
    }
  }
}

// Dns service
resource "kubernetes_service_v1" "pihole_dns" {
  metadata {
    name      = "pihole-dns"
    namespace = kubernetes_namespace.dns.metadata[0].name
    labels = {
      app = "pihole"
    }
    annotations = {
      "lbipam.cilium.io/ips" = var.load_balancer_ip
    }
  }
  spec {
    selector = {
      app = "pihole"
    }
    type = "LoadBalancer"
    port {
      port        = 53
      target_port = 53
      protocol    = "UDP"
      name        = "dns-udp"
    }
  }
}

// Web service and ingress
resource "kubernetes_service_v1" "pihole_web" {
  metadata {
    name      = "pihole-web"
    namespace = kubernetes_namespace.dns.metadata[0].name
    labels = {
      app = "pihole"
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "pihole"
    }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }
  }
}
resource "kubernetes_ingress_v1" "pihole" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.dns.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager"
    }
  }
  spec {
    rule {
      host = local.url
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.pihole_web.metadata[0].name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = [local.url]
      secret_name = "pihole-tls"
    }
  }
}
