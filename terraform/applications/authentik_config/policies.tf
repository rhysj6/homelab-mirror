resource "authentik_policy_expression" "secure-access" {
  name  = "secure-access"
  expression = <<EOT
if ak_user_has_authenticator(request.user):
    return True
ak_message("Some apps are hidden due to no MFA enabled. Enable MFA to see them.")
return False
EOT
}

resource "authentik_policy_expression" "local-access" {
  name  = "local-access"
  expression = "return ak_client_ip.is_private"
}