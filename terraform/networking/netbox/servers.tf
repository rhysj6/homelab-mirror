resource "netbox_vlan" "personal" {
  vid  = 11
  name = "GH personal"
}

resource "netbox_prefix" "personal" {
  prefix      = "10.10.1.0/24"
  status      = "active"
  description = "GH personal servers"
  vlan_id = netbox_vlan.personal.id
}

resource "netbox_ip_address" "personal_gw" {
  ip_address   = "10.10.1.1/24"
  description  = "GH personal servers Gateway"
  interface_id = netbox_device_interface.opnsense_lan.id
  object_type  = "dcim.interface"
  status       = "active"
}

resource "netbox_vlan" "temple" {
  vid  = 10
  name = "GH Temple"
}

resource "netbox_prefix" "temple" {
  prefix      = "10.10.2.0/24"
  status      = "active"
  description = "GH Temple"
  vlan_id = netbox_vlan.temple.id
}

resource "netbox_ip_address" "temple_gw" {
  ip_address   = "10.10.2.1/24"
  description  = "GH Temple Gateway"
  interface_id = netbox_device_interface.opnsense_lan.id
  object_type  = "dcim.interface"
  status       = "active"
}
