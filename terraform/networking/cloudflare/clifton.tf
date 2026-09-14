
locals {
  clifton_ingress = {
    hostname = "pve.example.com"
    service  = "https://10.0.0.20:8006"
    origin_request = {
      no_tls_verify = true
    }
  }
}

resource "cloudflare_dns_record" "clifton" {
  zone_id = data.cloudflare_zone.main.zone_id
  name    = local.clifton_ingress.hostname
  ttl     = 1
  type    = "CNAME"
  proxied = true
  content = "${cloudflare_zero_trust_tunnel_cloudflared.gh_opnsense.id}.cfargotunnel.com"
}

resource "cloudflare_zero_trust_access_application" "clifton" {
  name                      = "Proxmox Clifton"
  domain                    = local.clifton_ingress.hostname
  type                      = "self_hosted"
  account_id                = local.account_id
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.authentikl.id]
  app_launcher_visible      = true
  auto_redirect_to_identity = true
  destinations = [{
    type = "public"
    uri  = local.clifton_ingress.hostname
  }]
  policies = [{
    id = cloudflare_zero_trust_access_policy.allow_authentik.id
  }]
}
