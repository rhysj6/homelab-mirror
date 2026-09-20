
data "netbox_vlan" "personal" {
  name = "GH personal"
}

data "netbox_prefix" "personal" {
  vlan_id = data.netbox_vlan.personal.id
}

resource "proxmox_sdn_vnet" "personal" {
  id    = "personal"
  zone  = proxmox_sdn_zone_vlan.main.id
  alias = "Personal Util"
  tag   = data.netbox_vlan.personal.vid
}

resource "proxmox_sdn_subnet" "personal" {
  cidr    = data.netbox_prefix.personal.prefix
  vnet    = proxmox_sdn_vnet.personal.id
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
