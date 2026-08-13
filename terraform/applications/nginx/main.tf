locals {
  subdomain = "${var.cluster}-nginx"
  hostname = "${local.subdomain}.example.com"
}

resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.id
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    revision_history_limit = 2
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
          port {
            name           = "http"
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.id
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }
  }
}

resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.nginx.id
    annotations = {
    "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }
  spec {
    rule {
      host = local.hostname
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.nginx.metadata[0].name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}