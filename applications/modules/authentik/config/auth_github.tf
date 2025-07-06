resource "random_password" "github_client_id" {
  length = 20 ## This is imported from manually created GitHub OAuth app.
}

resource "random_password" "github_client_secret" {
  length = 40 ## This is imported from manually created GitHub OAuth app.
}

resource "authentik_source_oauth" "github" {
  name = "Github"
  slug = "github"

  provider_type   = "github"
  consumer_key    = random_password.github_client_id.result
  consumer_secret = random_password.github_client_secret.result

  user_matching_mode = "email_link"

  oidc_jwks_url       = "https://token.actions.githubusercontent.com/.well-known/jwks"
  oidc_well_known_url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"

  authentication_flow = data.authentik_flow.authorization-flow.id
}
