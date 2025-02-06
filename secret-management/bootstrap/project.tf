resource "infisical_project" "boostrap" {
  name        = "Bootstrap"
  slug        = "bootstrap"
  description = "Contains all the secrets required to bootstrap the the homelab"
}

resource "infisical_project_environment" "main" {
  name       = "Main"
  project_id = infisical_project.boostrap.id
  slug       = "main"
  position   = 1 # Optional
}