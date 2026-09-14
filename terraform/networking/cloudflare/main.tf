resource "cloudflare_zero_trust_tunnel_cloudflared" "gh_opnsense" {
  account_id = local.account_id
  name       = "gh-opnsense"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "gh_opnsense" {
  account_id = local.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.gh_opnsense.id
  config = {
    ingress = [
      local.clifton_ingress,
      {
        "service" : "http_status:404"
      }
    ]
  }
}
