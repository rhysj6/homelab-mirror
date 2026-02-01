locals {
  policy_required = (var.allowed_group != "" ? true : false) || var.secure_access || var.local_only_access

}

module "policy" {
  count             = local.policy_required ? 1 : 0
  source            = "git::https://github.com/rhysj6/homelab.git//terraform/modules/authentik_application_policy?ref=main"
  application_name  = var.name
  allowed_group     = var.allowed_group
  secure_access     = var.secure_access
  local_only_access = var.local_only_access
}

resource "authentik_policy_binding" "app-access" {
  count  = local.policy_required ? 1 : 0
  target = authentik_application.main.uuid
  policy = module.policy[0].id
  order  = 0
}
