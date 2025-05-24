resource "azuredevops_build_folder" "core_cluster_software" {
  project_id  = data.azuredevops_project.private.id
  path        = "\\Core-cluster"
  description = "Core cluster software folder"
}

resource "azuredevops_build_definition" "core_cluster_software" {
  for_each   = fileset("${path.module}/../clusters-core/", "*.yml")
  project_id = data.azuredevops_project.private.id
  name       = "core-cluster-${split(".", each.key)[0]}"
  path       = "\\Core-cluster"

  repository {
    repo_type             = "GitHub"
    repo_id               = "rhysj6/Homelab"
    branch_name           = "refs/heads/main"
    yml_path              = "pipelines/clusters-core/${each.key}"
    service_connection_id = data.azuredevops_serviceendpoint_github.rhysj6.id
  }
  ci_trigger {
    use_yaml = true
  }
  pull_request_trigger {
    use_yaml = true
    forks {
      enabled = false
      share_secrets = false
    }
  }
}
