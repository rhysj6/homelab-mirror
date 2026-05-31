unit "netbox" {
  source = "${get_repo_root()}/terraform/networking/netbox"
  path   = "netbox"
}

unit "gh_proxmox_sdn" {
  source = "${get_repo_root()}/terraform/networking/proxmox_sdn"
  path   = "gh_proxmox_sdn"
}
