resource "random_password" "minio_client_secret" {
  length = 128 ## This is being done this way to be able to import the secret into the authentik provider.
}

resource "authentik_provider_oauth2" "minio" {
  name               = "Minio - (Managed via Terraform)"
  client_id          = "dvJ3fb7S8PtnThqopKCXNJSZSvxIsELjZ0w0E06c"
  client_secret      = random_password.minio_client_secret.result
  authorization_flow = data.authentik_flow.authorization-flow.id
  signing_key        = data.authentik_certificate_key_pair.domain.id
  allowed_redirect_uris = [
    {
      url           = "https://minio.hl.${var.domain}/oauth_callback"
      matching_mode = "strict"
    }
  ]
  authentication_flow = data.authentik_flow.authorization-flow.id
  invalidation_flow   = data.authentik_flow.invalidation-flow.id
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
  ]
}

resource "authentik_application" "minio" {
  name              = "Minio"
  slug              = "minio"
  group             = "Infrastructure"
  meta_launch_url   = "https://minio.hl${var.domain}"
  open_in_new_tab   = true
  protocol_provider = authentik_provider_oauth2.minio.id
}

resource "authentik_policy_expression" "minio" {
  name       = "Minio"
  expression = <<-EOT
           if ak_is_group_member(request.user, name="Infrastructure Admin"):
             return {
                 "policy": "consoleAdmin",
           }
           return None
    EOT
}

resource "authentik_policy_binding" "minio" {
  target = authentik_application.minio.uuid
  policy = authentik_policy_expression.minio.id
  order  = 0
}
