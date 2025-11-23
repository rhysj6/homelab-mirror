resource "authentik_flow" "authentication" {
  name        = "main_authentication"
  title       = "Login"
  slug        = "main-authentication"
  designation = "authentication"
}

resource "authentik_stage_identification" "name" {
  name              = "main-ident"
  user_fields       = ["username", "email"]
  passwordless_flow = authentik_flow.passwordless_authentication.uuid
}


resource "authentik_flow_stage_binding" "main_authentication_identification_binding" {
  target = authentik_flow.authentication.uuid
  stage  = authentik_stage_identification.name.id
  order  = 10
}

resource "authentik_stage_password" "password_stage" {
  name                = "password-stage"
  allow_show_password = true
  backends            = ["authentik.core.auth.InbuiltBackend"]
}



resource "authentik_flow_stage_binding" "main_authentication_password_binding" {
  target = authentik_flow.authentication.uuid
  stage  = authentik_stage_password.password_stage.id
  order  = 20
}

resource "authentik_policy_expression" "show_password_stage" {
  name       = "show_password_stage"
  expression = <<EOF
flow_plan = request.context.get("flow_plan")
if not flow_plan:
    return True
# If the user does not have a backend attached to it, they haven't
# been authenticated yet and we need the password stage
return not hasattr(flow_plan.context.get("pending_user"), "backend")
EOF
}

resource "authentik_policy_binding" "show_password_stage_binding" {
  target = authentik_flow_stage_binding.main_authentication_password_binding.id
  policy = authentik_policy_expression.show_password_stage.id
  order  = 0
}

resource "authentik_stage_authenticator_webauthn" "webauthn_setup" {
  name = "webauthn-setup"
}

resource "authentik_stage_authenticator_validate" "mfa_validation" {
  name                  = "mfa-stage"
  device_classes = ["webauthn"]
  not_configured_action = "configure"
  configuration_stages = [
    authentik_stage_authenticator_webauthn.webauthn_setup.id
  ]
}


resource "authentik_flow_stage_binding" "main_authentication_mfa_binding" {
  target = authentik_flow.authentication.uuid
  stage  = authentik_stage_authenticator_validate.mfa_validation.id
  order  = 30
}

resource "authentik_policy_expression" "private_ip_only" {
  name       = "private_ip_only"
  expression = "return ak_client_ip.is_private"
}

resource "authentik_policy_binding" "show_mfa_stage_binding" {
  target = authentik_flow_stage_binding.main_authentication_mfa_binding.id
  policy = authentik_policy_expression.private_ip_only.id
  negate = true
  order  = 0
}


resource "authentik_stage_user_login" "login" {
  name          = "user-login"
  geoip_binding = "bind_continent_country"
}



resource "authentik_flow_stage_binding" "main_authentication_login_binding" {
  target = authentik_flow.authentication.uuid
  stage  = authentik_stage_user_login.login.id
  order  = 50
}
