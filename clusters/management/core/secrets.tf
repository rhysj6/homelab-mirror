
data "infisical_projects" "bootstrap-project" {
  slug = "bootstrap"
}

data "infisical_projects" "kubernetes-project" {
  slug = "kubernetes"
}

data "infisical_secrets" "bootstrap_secrets" {
  env_slug     = "main"
  workspace_id = data.infisical_projects.bootstrap-project.id
  folder_path  = "/"
}

data "infisical_secrets" "kubernetes_secrets" {
  env_slug     = local.environment
  workspace_id = data.infisical_projects.kubernetes-project.id
  folder_path  = "/"
}