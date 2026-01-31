locals {
  policy_required = (var.allowed_group != "" ? true : false) || var.secure_access || var.local_only_access 
}

resource "authentik_policy_expression" "app-access" {
  count = local.policy_required ? 1 : 0
  name  = "${var.name} - App Access Policy"
  expression = <<EOT
%{ if var.allowed_group != "" ~}
if not ak_is_group_member(request.user, name="${var.allowed_group}"):
  return False
%{ endif ~}

%{ if var.local_only_access ~}
result = ak_call_policy("local-access")
if not result.passing:
    return False
%{ endif ~}
%{ if var.secure_access ~}
result = ak_call_policy("secure-access")
if not result.passing:
    return False
%{ endif ~}
return True
EOT
}

resource "authentik_policy_binding" "app-access" {
  count  = local.policy_required ? 1 : 0
  target = authentik_application.main.uuid
  policy = authentik_policy_expression.app-access[0].id
  order  = 0
}
