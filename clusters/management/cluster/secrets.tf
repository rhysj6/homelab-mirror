
data "infisical_projects" "bootstrap-project" {
  slug = "bootstrap"
}

data "infisical_secrets" "bootstrap_secrets" {
  env_slug     = "main"
  workspace_id = data.infisical_projects.bootstrap-project.id
  folder_path  = "/"
}