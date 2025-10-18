locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket         = "terraform"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region                      = "main"
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }
}
EOF
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents = file("${get_repo_root()}/terragrunt/versions.tf")
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "skip" # The talos modules generate the secrets so we skip this file there
  contents = <<EOF
ephemeral "infisical_secret" "kubernetes_host" {
  name         = "HOST"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/kubeconfigs/${local.env_vars.locals.cluster}"
}
ephemeral "infisical_secret" "kubernetes_cluster_ca_certificate" {
  name         = "CLUSTER_CA_CERTIFICATE"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/kubeconfigs/${local.env_vars.locals.cluster}"
}

ephemeral "infisical_secret" "kubernetes_client_certificate" {
  name         = "CLIENT_CERTIFICATE"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/kubeconfigs/${local.env_vars.locals.cluster}"
}

ephemeral "infisical_secret" "kubernetes_client_key" {
  name         = "CLIENT_KEY"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/kubeconfigs/${local.env_vars.locals.cluster}"
}


provider "kubernetes" {
    host = ephemeral.infisical_secret.kubernetes_host.value
    cluster_ca_certificate = ephemeral.infisical_secret.kubernetes_cluster_ca_certificate.value
    client_certificate = ephemeral.infisical_secret.kubernetes_client_certificate.value
    client_key = ephemeral.infisical_secret.kubernetes_client_key.value
}

provider "helm" {
  kubernetes = {
    host                   = ephemeral.infisical_secret.kubernetes_host.value
    cluster_ca_certificate = ephemeral.infisical_secret.kubernetes_cluster_ca_certificate.value
    client_certificate     = ephemeral.infisical_secret.kubernetes_client_certificate.value
    client_key             = ephemeral.infisical_secret.kubernetes_client_key.value
  }
}
EOF
}
