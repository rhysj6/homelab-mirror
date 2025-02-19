resource "authentik_group" "infra_admin" {
  name         = "Infrastructure Admin"
  is_superuser = true
}