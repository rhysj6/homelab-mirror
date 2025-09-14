resource "kubernetes_service_v1" "minio_1" {
  metadata {
    name      = "minio-1"
    namespace = kubernetes_namespace.external_hosts.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = "10.10.0.141"
    port {
      port        = 9000
      target_port = 9000
      name        = "api" # S3 port
    }
    port {
      port        = 9001
      target_port = 9001
      name        = "console" # Console port
    }
  }
}

resource "kubernetes_service_v1" "minio_2" {
  metadata {
    name      = "minio-2"
    namespace = kubernetes_namespace.external_hosts.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = "10.10.0.142"
    port {
      port        = 9000
      target_port = 9000
      name        = "api" # S3 port
    }
    port {
      port        = 9001
      target_port = 9001
      name        = "console" # Console port
    }
  }
}

resource "kubernetes_ingress_v1" "minio_s3_ingress" { # Going to have some instance specific ingress resources
  # This is the main ingress resource for minio
  metadata {
    name      = "minio-s3-ingress"
    namespace = "external-hosts"
    annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager"
    }
  }
  spec {
    rule {
      host = "s3.hl.${var.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.minio_1.metadata[0].name
              port {
                name = "api"
              }
            }
          }
        }
      }
    }
    rule {
      host = "s3-1.hl.${var.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.minio_1.metadata[0].name
              port {
                name = "api"
              }
            }
          }
        }
      }
    }
    rule {
      host = "s3-2.hl.${var.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.minio_2.metadata[0].name
              port {
                name = "api"
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "minio-s3-tls"
      hosts = [
        "s3.hl.${var.domain}",
        "s3-1.hl.${var.domain}",
        "s3-2.hl.${var.domain}"
      ]
    }
  }
}

resource "kubernetes_ingress_v1" "minio_console_ingress" { # Going to have some instance specific ingress resources
  # This is the main ingress resource for minio
  metadata {
    name      = "minio-console-ingress"
    namespace = "external-hosts"
    annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager",
      "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-local-only@kubernetescrd"
    }
  }
  spec {
    rule {
      host = "minio.hl.${var.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.minio_1.metadata[0].name
              port {
                name = "console"
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "minio-console-tls"
      hosts = [
        "minio.hl.${var.domain}"
      ]
    }
  }
}