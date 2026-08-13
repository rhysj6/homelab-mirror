locals {
  account_id = "cfacid"
}
resource "random_password" "tunnel_secret" {
  length  = 32
  special = true
  numeric = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "main" {
  account_id    = local.account_id
  name          = "${var.cluster}-cluster"
  config_src    = "local"
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "main_token" {
	account_id 	= local.account_id
	tunnel_id 	= cloudflare_zero_trust_tunnel_cloudflared.main.id
    depends_on = [ 
        cloudflare_zero_trust_tunnel_cloudflared.main
     ]
}

resource "kubernetes_namespace_v1" "cloudflared" {
  metadata {
    name = "cloudflared"
  }
}

resource "kubernetes_secret_v1" "tunnel_secret" {
  metadata {
    name      = "main-tunnel-secret"
    namespace = kubernetes_namespace_v1.cloudflared.id
  }
  data = {
    TUNNEL_TOKEN = data.cloudflare_zero_trust_tunnel_cloudflared_token.main_token.token
  }
}

resource "kubernetes_config_map_v1" "cloudflared_config" {
  metadata {
    name      = "main-cloudflared-config"
    namespace = "cloudflared"
  }

  data = {
    "config.yaml" = yamlencode({
      tunnel = "${cloudflare_zero_trust_tunnel_cloudflared.main.id}"

      ingress = [
        {
          service = "http://traefik.traefik.svc.cluster.local:443"
        }
      ]
    })
  }
}

# A simple way to share this tunnel id without needing to track what cluster something is being deployed to
resource "kubernetes_config_map_v1" "main_tunnel_domain" {
  metadata {
    name      = "main-tunnel-domain"
    namespace = "cloudflared"
  }

  data = {
    id = "${cloudflare_zero_trust_tunnel_cloudflared.main.id}"
    domain =  "${cloudflare_zero_trust_tunnel_cloudflared.main.id}.cfargotunnel.com"
  }
}

resource "kubernetes_deployment_v1" "cloudflared" {
  metadata {
    name      = "main-cloudflared"
    namespace = kubernetes_namespace_v1.cloudflared.id
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "cloudflared"
      }
    }
    revision_history_limit = 2
    template {
      metadata {
        labels = {
          app = "cloudflared"
        }
      }
      spec {
        security_context {
          sysctl {
            # Allows ICMP traffic (ping, traceroute) to resources behind cloudflared.
            name  = "net.ipv4.ping_group_range"
            value = "65532 65532"
          }
        }
        container {
          name  = "cloudflared"
          image = "cloudflare/cloudflared:2026.7.3"
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.tunnel_secret.metadata[0].name
            }
          }

          args = [
            "tunnel",
            "--config", "/etc/cloudflared/config/config.yaml",
            "--no-autoupdate",
            "--metrics", "0.0.0.0:2000",
            "run",
          ]

          volume_mount {
            name       = "config"
            mount_path = "/etc/cloudflared/config"
            read_only  = true
          }

          liveness_probe {
            http_get {
              path = "/ready"
              port = 2000
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.cloudflared_config.metadata[0].name
          }
        }
      }
    }
  }
}
