resource "proxmox_sdn_vnet" "notrust" {
  id    = "notrust"
  zone  = proxmox_sdn_zone_evpn.main.id
  alias = "Third part DMZ"
  tag   = 1910
}

resource "proxmox_sdn_subnet" "notrust" {
  cidr    = "10.48.17.0/24"
  vnet    = proxmox_sdn_vnet.notrust.id
  gateway = "10.48.17.2"
}

resource "netbox_prefix" "notrust" {
  prefix      = proxmox_sdn_subnet.notrust.cidr
  status      = "active"
  description = "GH notrust"
}
