
data "infisical_projects" "bootstrap" {
  slug = "bootstrap"
}

data "infisical_secrets" "bootstrap" {
  env_slug     = "main"
  workspace_id = data.infisical_projects.bootstrap.id
  folder_path  = "/"
}
