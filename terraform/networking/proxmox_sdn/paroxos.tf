data "netbox_vlan" "paroxos" {
  name = "GH paroxos"
}

data "netbox_prefix" "parox" {
  vlan_id = data.netbox_vlan.paroxos.id
}

resource "proxmox_sdn_vnet" "paroxos" {
  id    = "paroxos"
  zone  = proxmox_sdn_zone_vlan.main.id
  alias = "Parox - OS GH"
  tag   = data.netbox_vlan.paroxos.vid
}

resource "proxmox_sdn_subnet" "paroxos" {
  cidr = data.netbox_prefix.parox.prefix
  vnet = proxmox_sdn_vnet.paroxos.id
}

resource "netbox_ip_address" "paroxos_gw" {
  ip_address  = "10.48.0.1/24"
  description = "GH paroxos Gateway"
  role        = "vip"
  status      = "active"
}
