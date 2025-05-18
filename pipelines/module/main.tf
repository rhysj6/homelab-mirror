data "azuredevops_project" "private" {
  name = "Homelab"
}

data "azuredevops_serviceendpoint_github" "rhysj6" {
  project_id            = data.azuredevops_project.private.id
  service_endpoint_name = "rhysj6"
}

resource "azuredevops_build_definition" "pipeline_provisioner" {
  project_id = data.azuredevops_project.private.id
  name       = "Pipeline Provisioner"

  repository {
    repo_type             = "GitHub"
    repo_id               = "rhysj6/Homelab"
    branch_name           = "refs/heads/main"
    yml_path              = "pipelines/provisioning.yml"
    service_connection_id = data.azuredevops_serviceendpoint_github.rhysj6.id
  }
  ci_trigger {
    use_yaml = true
  }
}

resource "azuredevops_group" "approvers" {
  scope        = data.azuredevops_project.private.id
  display_name = "Deployment Approvers"
  description  = "Users who can approve automated deployments"
}