resource "kubernetes_service_v1" "clifton_minio" {
  metadata {
    name      = "clifton-minio"
    namespace = kubernetes_namespace.external_hosts.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = "10.10.0.131"
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

resource "kubernetes_service_v1" "filton_minio" {
  metadata {
    name      = "filton-minio"
    namespace = kubernetes_namespace.external_hosts.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = "10.10.0.132"
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

resource "kubernetes_ingress_v1" "minio_main_ingress" { # Going to have some instance specific ingress resources
  # This is the main ingress resource for minio
  metadata {
    name      = "minio-ingress"
    namespace = "external-hosts"
    annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager"
    }
  }
  spec {
    rule {
      host = "minio.hl.${local.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.clifton_minio.metadata[0].name
              port {
                name = "console"
              }
            }
          }
        }
      }
    }
    rule {
      host = "s3.hl.${local.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.clifton_minio.metadata[0].name
              port {
                name = "api"
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "minio-main-tls"
      hosts = [
        "minio.hl.${local.domain}",
        "s3.hl.${local.domain}"
      ]
    }
  }
}


resource "kubernetes_ingress_v1" "minio_clifton_ingress" { # Clifton specific ingress resource
  metadata {
    name      = "clifton-minio-ingress"
    namespace = "external-hosts"
    annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager"
    }
  }
  spec {
    rule {
      host = "minio.clifton.hl.${local.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.clifton_minio.metadata[0].name
              port {
                name = "console"
              }
            }
          }
        }
      }
    }
    rule {
      host = "s3.clifton.hl.${local.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.clifton_minio.metadata[0].name
              port {
                name = "api"
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "minio-clifton-tls"
      hosts = [
        "minio.clifton.hl.${local.domain}",
        "s3.clifton.hl.${local.domain}"
      ]
    }
  }
}


resource "kubernetes_ingress_v1" "minio_filton_ingress" { # filton specific ingress resource
  metadata {
    name      = "filton-minio-ingress"
    namespace = "external-hosts"
    annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager"
    }
  }
  spec {
    rule {
      host = "minio.filton.hl.${local.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.filton_minio.metadata[0].name
              port {
                name = "console"
              }
            }
          }
        }
      }
    }
    rule {
      host = "s3.filton.hl.${local.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.filton_minio.metadata[0].name
              port {
                name = "api"
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "minio-filton-tls"
      hosts = [
        "minio.filton.hl.${local.domain}",
        "s3.filton.hl.${local.domain}"
      ]
    }
  }
}
