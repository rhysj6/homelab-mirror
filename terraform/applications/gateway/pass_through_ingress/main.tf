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
  local_annotations = {
    "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-local-only@kubernetescrd"
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = var.name
    namespace = "external-hosts"
    annotations = merge({
      "cert-manager.io/cluster-issuer" = "cert-manager"
      },
      var.local-only ? local.local_annotations : {},
    var.extra-ingress-annotations)
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
