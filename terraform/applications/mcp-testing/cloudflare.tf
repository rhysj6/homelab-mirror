locals {
  portal_hostname = "${var.cluster}-mcp-portal.example.com"
}

resource "cloudflare_dns_record" "nginx" {
  zone_id = data.cloudflare_zone.main.id
  name    = local.subdomain
  type    = "CNAME"
  content = data.kubernetes_config_map_v1.tunnel.data.domain
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "mcp_portal" {
  zone_id = data.cloudflare_zone.main.id
  name    = local.portal_hostname
  content = "gateway.agents.cloudflare.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}


resource "cloudflare_zero_trust_access_ai_controls_mcp_server" "main" {
  account_id = "cfacid"
  id         = local.subdomain
  hostname   = "https://${local.hostname}/mcp"
  name       = local.subdomain
  auth_type  = "oauth"
  auth_credentials = jsonencode({
    auth_mode = "manual"
    registration_info = {
      client_id                  = random_password.client_id.result
      scope                      = "openid profile email"
      token_endpoint_auth_method = "client_secret_post"
    }
    has_client_secret = true
    config = {
      authorization_endpoint = "https://homelab.example/application/o/authorize/"
      issuer                 = "https://homelab.example/application/o/mcp-test/"
      token_endpoint         = "https://homelab.example/application/o/token/"
    }
  })
  client_secret                    = authentik_provider_oauth2.main.client_secret
  description                      = "Testing MCP server"
  is_shared_oauth_callback_enabled = true

  secure_web_gateway = false
}

resource "cloudflare_zero_trust_access_ai_controls_mcp_portal" "main" {
  account_id         = "cfacid"
  id                 = "testing-mcp-portal"
  hostname           = local.portal_hostname
  name               = "Testing MCP portal"
  allow_code_mode    = false
  description        = "This is my custom MCP Portal"
  secure_web_gateway = false
  servers = [{
    server_id        = cloudflare_zero_trust_access_ai_controls_mcp_server.main.id
    default_disabled = false
    on_behalf        = true
  }]
}

resource "cloudflare_zero_trust_access_application" "portal" {
  domain = local.portal_hostname
  type   = "mcp_portal"
  zone_id = data.cloudflare_zone.main.id
  
  allowed_idps = ["a9463b2d-bdad-43e7-bf2d-601e4b52b433"]

  name = cloudflare_zero_trust_access_ai_controls_mcp_portal.main.name
  policies = [{
    id = "72dcf13c-1a41-49bc-b365-d0de73b76a64"
    precedence = 1
  }]
}

resource "cloudflare_zero_trust_access_application" "server" {
  # domain = local.hostname
  type   = "mcp"
  zone_id = data.cloudflare_zone.main.id
  
  allowed_idps = ["a9463b2d-bdad-43e7-bf2d-601e4b52b433"]

  destinations = [ {
    type = "via_mcp_server_portal"
    mcp_server_id = cloudflare_zero_trust_access_ai_controls_mcp_server.main.id
  } ]

  name = cloudflare_zero_trust_access_ai_controls_mcp_server.main.name
  policies = [{
    id = "72dcf13c-1a41-49bc-b365-d0de73b76a64"
    precedence = 1
  }]
  
}