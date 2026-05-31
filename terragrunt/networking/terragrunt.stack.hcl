unit "general" {
  source = "${get_repo_root()}/terraform/networking/general"
  path   = "general"
}

unit "gh_proxmox_sdn" {
  source = "${get_repo_root()}/terraform/networking/proxmox_sdn"
  path   = "gh_proxmox_sdn"
}
