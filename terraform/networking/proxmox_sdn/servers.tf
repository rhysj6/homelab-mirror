resource "proxmox_sdn_vnet" "personal" {
  id    = "personal"
  zone  = proxmox_sdn_zone_evpn.main.id
  alias = "Personal Util"
  tag   = 30
}

resource "proxmox_sdn_subnet" "personal" {
  cidr    = "10.10.1.0/24"
  vnet    = proxmox_sdn_vnet.personal.id
  gateway = "10.10.1.1"
}

data "netbox_vlan" "temple" {
  name = "GH Temple"
}

data "netbox_prefix" "temple" {
  vlan_id = data.netbox_vlan.temple.id
}

resource "proxmox_sdn_vnet" "temple" {
  id    = "temple"
  zone  = proxmox_sdn_zone_vlan.main.id
  alias = "Temple"
  tag   = data.netbox_vlan.temple.vid
}

resource "proxmox_sdn_subnet" "temple" {
  cidr = data.netbox_prefix.temple.prefix
  vnet = proxmox_sdn_vnet.temple.id
}
