resource "random_password" "client_id" {
  length = 40
}

resource "authentik_provider_oauth2" "main" {
  name               = "Cloudflare access (Managed via Terraform)"
  authorization_flow = data.authentik_flow.authorization.id
  signing_key        = data.authentik_certificate_key_pair.main.id
  invalidation_flow  = data.authentik_flow.logout.id
  client_id          = random_password.client_id.result
  property_mappings = [
    data.authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.profile.id,
  ]
  allowed_redirect_uris = [{
    url           = "https://${data.cloudflare_zero_trust_organization.main.auth_domain}/cdn-cgi/access/callback"
    matching_mode = "strict"
    redirect_uri_type = "authorization" 
  }]
  grant_types = [
    "authorization_code",
    "implicit",
    "hybrid",
    "refresh_token"
  ]
}

resource "authentik_application" "main" {
  name              = "Cloudflare access"
  slug              = "cloudflare"
  protocol_provider = authentik_provider_oauth2.main.id
  meta_hide = true
}

resource "cloudflare_zero_trust_access_identity_provider" "authentikl" {
  config = {
    scopes           = ["openid", "email", "profile"]
    client_id        = authentik_provider_oauth2.main.client_id
    client_secret    = authentik_provider_oauth2.main.client_secret
    email_claim_name = "email"
    auth_url         = "https://homelab.example/application/o/authorize/"
    token_url        = "https://homelab.example/application/o/token/"
    certs_url        = "https://homelab.example/application/o/cloudflare/jwks/"
  }
  name       = "Authentik"
  type       = "oidc"
  account_id = local.account_id
}

resource "cloudflare_zero_trust_access_policy" "allow_authentik" {
  account_id = local.account_id
  decision = "allow"
  name = "Allow Authentik"
  include = [{
    login_method = {
      id = cloudflare_zero_trust_access_identity_provider.authentikl.id
    }
  }]
}
