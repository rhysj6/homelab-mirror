resource "random_password" "client_id" {
  length  = 32
}


resource "authentik_provider_oauth2" "main" {
  name               = "MCP Testing - (Managed via Terraform)"
  authorization_flow = data.authentik_flow.authorization.id
  signing_key        = data.authentik_certificate_key_pair.main.id
  invalidation_flow   = data.authentik_flow.logout.id
  client_id          = random_password.client_id.result
  property_mappings = [
    data.authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.profile.id,
  ]
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      redirect_uri_type = "authorization"
      url           = "https://oauth-callbacks.cloudflareaccess.com/cdn-cgi/access/outbound-oauth-callback"
    }
  ]
  grant_types = [
    "authorization_code"
  ]
}

resource "authentik_application" "main" {
  name              = "MCP Testing"
  slug              = "mcp-test"
  protocol_provider = authentik_provider_oauth2.main.id
}