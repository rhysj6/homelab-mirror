resource "azuredevops_environment" "test" {
  project_id = data.azuredevops_project.private.id
  name       = "Test"
}


resource "azuredevops_check_exclusive_lock" "test_environment" {
  project_id           = data.azuredevops_project.private.id
  target_resource_id   = azuredevops_environment.test.id
  target_resource_type = "environment"
  timeout = 1440
}

resource "azuredevops_environment" "production" {
  project_id = data.azuredevops_project.private.id
  name       = "Production"
}


resource "azuredevops_check_exclusive_lock" "production_environment" {
  project_id           = data.azuredevops_project.private.id
  target_resource_id   = azuredevops_environment.production.id
  target_resource_type = "environment"
  timeout = 1440
}