resource "authentik_flow" "passwordless_authentication" {
  name        = "passwordless"
  title       = "Passkey Login"
  slug        = "passwordless-authentication"
  designation = "authentication"
}

resource "authentik_stage_authenticator_validate" "passwordless_webauthn_stage" {
  name                  = "webauthn-login-stage"
  not_configured_action = "deny"
  device_classes        = ["webauthn"]
  webauthn_user_verification = "required"
}

resource "authentik_flow_stage_binding" "passwordless_webauthn_binding" {
  target = authentik_flow.passwordless_authentication.uuid
  stage  = authentik_stage_authenticator_validate.passwordless_webauthn_stage.id
  order  = 10
}


resource "authentik_flow_stage_binding" "webauthn_login_binding" {
  target = authentik_flow.passwordless_authentication.uuid
  stage  = authentik_stage_user_login.login.id
  order  = 20
}


