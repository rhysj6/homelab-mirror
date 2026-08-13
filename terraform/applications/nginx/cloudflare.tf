
data "cloudflare_zone" "main" {
  filter = {
    name = "example.com"
  }
}

data "kubernetes_config_map_v1" "tunnel" {
  metadata {
    name = "main-tunnel-domain"
    namespace = "cloudflared"
  }
}

resource "cloudflare_dns_record" "nginx" {
  zone_id = data.cloudflare_zone.main.id
  name    = "${local.subdomain}"
  type    = "CNAME"
  content = data.kubernetes_config_map_v1.tunnel.data.domain
  ttl     = 1
  proxied = true
}


