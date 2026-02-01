
resource "authentik_policy_expression" "app-access" {
  name  = "${var.application_name} - App Access Policy"
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

output "id" {
  description = "Policy ID"
  value = authentik_policy_expression.app-access.id
}