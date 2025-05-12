resource "azuredevops_build_folder" "applications" {
  project_id  = azuredevops_project.private.id
  path        = "\\Applications"
  description = "Applications folder"
}

resource "azuredevops_build_definition" "applications" {
  for_each   = fileset("${path.module}/pipelines/applications/", "*.yml")
  project_id = azuredevops_project.private.id
  name       = "${each.key}"
  path       = "\\Applications"

  repository {
    repo_type             = "GitHub"
    repo_id               = "rhysj6/Homelab"
    yml_path              = "pipelines/applications/${each.key}"
    service_connection_id = data.azuredevops_serviceendpoint_github.rhysj6.id
  }
}
