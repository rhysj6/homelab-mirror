resource "kubernetes_service_v1" "service" {
  metadata {
    name      = var.name
    namespace = "external-hosts"
  }
  spec {
    type          = "ExternalName"
    external_name = var.ip_address
    port {
      port        = var.port
      target_port = var.port
      name        = var.portname
    }
  }
}

locals {
    base_annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager"
    }
    optional_annotations = {
        exists = {
            "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-${var.middleware}@kubernetescrd"
        }
        not_exists = {}
    }
    annotations = "${merge(
        local.base_annotations,
        local.optional_annotations[var.middleware != "" ? "exists" : "not_exists"]
    )}"
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = var.name
    namespace = "external-hosts"
    annotations = local.annotations
  }
  spec {
    rule {
      host = var.hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.service.metadata[0].name
              port {
                number = var.port
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "${var.name}-tls"
      hosts       = [var.hostname]
    }
  }
}
