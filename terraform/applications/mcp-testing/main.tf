locals {
  subdomain = "${var.cluster}-mcp-test"
  hostname = "${local.subdomain}.example.com"
}

resource "kubernetes_namespace" "mcp_test" {
  metadata {
    name = "mcp-test"
  }
}

resource "kubernetes_deployment" "mcp_test" {
  metadata {
    name      = "mcp-test"
    namespace = kubernetes_namespace.mcp_test.id
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mcp-test"
      }
    }
    revision_history_limit = 2
    template {
      metadata {
        labels = {
          app = "mcp-test"
        }
      }
      spec {
        container {
          name  = "mcp-test"
          image = "rhysj6/mcp-testing:v0.1.3"

          port {
            name           = "http"
            container_port = 8000
          }
          env {
            name = "CLIENT_ID"
            value = random_password.client_id.result
          }
          env {
            name = "ISSUER_URL"
            value = "https://homelab.example/application/o/mcp-test/"
          }
          env {
            name = "OBO_URL"
            value = "https://homelab.example/application/o/token/"
          }
          env {
            name = "BASE_URL"
            value = "https://${local.hostname}"
          }
          env {
            name = "GRAFANA_URL"
            value = "https://grafana.homelab.example"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mcp_test" {
  metadata {
    name      = "mcp-test"
    namespace = kubernetes_namespace.mcp_test.id
  }
  spec {
    selector = {
      app = "mcp-test"
    }
    port {
      name        = "http"
      port        = 8000
      target_port = "http"
    }
  }
}

resource "kubernetes_ingress_v1" "mcp_test" {
  metadata {
    name      = "mcp-test"
    namespace = kubernetes_namespace.mcp_test.id
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
              name = kubernetes_service.mcp_test.metadata[0].name
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