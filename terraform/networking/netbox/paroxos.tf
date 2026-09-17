resource "netbox_vlan" "paroxos" {
  vid  = 3010
  name = "GH paroxos"
}

resource "netbox_prefix" "paroxos" {
  prefix      = "10.48.0.0/24"
  status      = "active"
  description = "GH paroxos"
  vlan_id = netbox_vlan.paroxos.id
}

resource "netbox_ip_address" "paroxos_gw" {
  ip_address   = "10.48.0.1/24"
  description  = "GH paroxos Gateway"
  interface_id = netbox_device_interface.opnsense_lan.id
  object_type  = "dcim.interface"
  status       = "active"
}
