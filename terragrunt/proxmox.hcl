
generate "proxmox_providers" {
  path      = "proxmox_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
ephemeral "infisical_secret" "grh_proxmox_api_key" {
  name         = "GRH_API_KEY"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/proxmox"
}
provider "proxmox" {
  endpoint  = "https://pve.homelab.example/"
  api_token = ephemeral.infisical_secret.grh_proxmox_api_key.value
}
EOF
}
