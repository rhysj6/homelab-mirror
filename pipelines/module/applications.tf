resource "azuredevops_build_folder" "applications" {
  project_id  = data.azuredevops_project.private.id
  path        = "\\Applications"
  description = "Applications folder"
}

resource "azuredevops_build_definition" "applications" {
  for_each   = fileset("${path.module}/../applications/", "*.yml")
  project_id = data.azuredevops_project.private.id
  name       = each.key
  path       = "\\Applications"

  repository {
    repo_type   = "GitHub"
    repo_id     = "rhysj6/Homelab"
    branch_name = "refs/heads/main"
    yml_path              = "pipelines/applications/${each.key}"
    service_connection_id = data.azuredevops_serviceendpoint_github.rhysj6.id
  }
  ci_trigger {
    use_yaml = true
  }
}
