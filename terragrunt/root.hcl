locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  s3_path  = "${replace(path_relative_to_include(), "//.terragrunt-stack//", "/")}"
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "terraform"
    key            = "${local.s3_path}/terraform.tfstate"
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
  contents  = file("${get_repo_root()}/terraform/versions.tf")
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = file("${get_repo_root()}/terraform/providers.tf")
}

generate "proxmox_providers" {
  path      = "proxmox_providers.tf"
  if_exists = "skip" # The talos modules generate the secrets so we skip this file there
  contents  = <<EOF
ephemeral "infisical_secret" "grh_proxmox_host" {
  name         = "GRH_HOST"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/proxmox"
}

ephemeral "infisical_secret" "grh_proxmox_api_key" {
  name         = "GRH_API_KEY"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/proxmox"
}

ephemeral "infisical_secret" "chk_proxmox_host" {
  name         = "CHK_HOST"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/proxmox"
}

ephemeral "infisical_secret" "chk_proxmox_api_key" {
  name         = "CHK_API_KEY"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/proxmox"
}

provider "proxmox" {
  endpoint  = ephemeral.infisical_secret.grh_proxmox_host.value
  api_token = ephemeral.infisical_secret.grh_proxmox_api_key.value
  insecure  = true
  alias     = "grh"
}

provider "proxmox" {
  endpoint  = ephemeral.infisical_secret.chk_proxmox_host.value
  api_token = ephemeral.infisical_secret.chk_proxmox_api_key.value
  insecure  = true
  alias     = "chk"
}

EOF
}


generate "kubernetes_providers" {
  path      = "kubernetes_providers.tf"
  if_exists = "skip" # The talos modules generate the secrets so we skip this file there
  contents  = <<EOF
ephemeral "infisical_secret" "kubernetes_host" {
  name         = "${upper(local.env_vars.locals.cluster)}_HOST"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/kubeconfigs"
}
ephemeral "infisical_secret" "kubernetes_cluster_ca_certificate" {
  name         = "${upper(local.env_vars.locals.cluster)}_CLUSTER_CA_CERTIFICATE"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/kubeconfigs"
}

ephemeral "infisical_secret" "kubernetes_client_certificate" {
  name         = "${upper(local.env_vars.locals.cluster)}_CLIENT_CERTIFICATE"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/kubeconfigs"
}

ephemeral "infisical_secret" "kubernetes_client_key" {
  name         = "${upper(local.env_vars.locals.cluster)}_CLIENT_KEY"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/kubeconfigs"
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
