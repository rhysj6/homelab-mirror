resource "infisical_project" "kubernetes" {
  name        = "Kubernetes"
  slug        = "kubernetes"
  description = "Contains all the resources related to the Kubernetes clusters"
}

resource "infisical_project_environment" "test" {
  name       = "test"
  project_id = infisical_project.kubernetes.id
  slug       = "test"
  position   = 2 # Optional
}

resource "infisical_project_environment" "redcliff" {
  name       = "redcliff"
  project_id = infisical_project.kubernetes.id
  slug       = "redcliff"
  position   = 1 # Optional
}