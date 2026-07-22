locals {
    env = yamldecode(file(find_in_parent_folders("env.yaml")))
}

generate "proxmox_providers" {
  path      = "proxmox_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
ephemeral "infisical_secret" "proxmox_host" {
  name         = "${upper(local.env.proxmox_cluster)}_HOST"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/proxmox"
}

ephemeral "infisical_secret" "proxmox_api_key" {
  name         = "${upper(local.env.proxmox_cluster)}_API_KEY"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/proxmox"
}
provider "proxmox" {
  endpoint  = ephemeral.infisical_secret.proxmox_host.value
  api_token = ephemeral.infisical_secret.proxmox_api_key.value
}
EOF
}
