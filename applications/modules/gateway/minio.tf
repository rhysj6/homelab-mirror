resource "kubernetes_service_v1" "minio_1" {
  metadata {
    name      = "minio-1"
    namespace = kubernetes_namespace.external_hosts.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = "10.10.0.141"
    port {
      name        = "https"
      port        = 9000
      target_port = 9000
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
      name        = "https"
      port        = 9000
      target_port = 9000
    }
  }
}

resource "kubernetes_ingress_v1" "minio_ingress" {
  metadata {
    name      = "minio-ingress"
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
                name = "https"
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
                name = "https"
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
                name = "https"
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
