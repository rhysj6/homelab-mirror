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
  public_annotations = {
    "cert-manager.io/cluster-issuer" = "cert-manager"
  }
  local_annotations = {
    "cert-manager.io/cluster-issuer"                   = "infisical"
    "cert-manager.io/common-name"                      = var.hostname
    "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-local-only@kubernetescrd"
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = var.name
    namespace = "external-hosts"
    annotations = merge(
      var.local-only ? local.local_annotations : local.public_annotations,
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
