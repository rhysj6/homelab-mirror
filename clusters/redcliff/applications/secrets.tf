
data "infisical_projects" "bootstrap" {
  slug = "bootstrap"
}

data "infisical_projects" "kubernetes" {
  slug = "kubernetes"
}

data "infisical_secrets" "bootstrap" {
  env_slug     = "main"
  workspace_id = data.infisical_projects.bootstrap.id
  folder_path  = "/"
}

data "infisical_secrets" "kubernetes" {
  env_slug     = "redcliff"
  workspace_id = data.infisical_projects.kubernetes.id
  folder_path  = "/"
}