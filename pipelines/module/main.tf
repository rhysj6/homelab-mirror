data "azuredevops_project" "private" {
  name = "Homelab"
}

data "azuredevops_serviceendpoint_github" "rhysj6" {
  project_id            = data.azuredevops_project.private.id
  service_endpoint_name = "rhysj6"
}
