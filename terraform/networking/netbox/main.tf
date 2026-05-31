
resource "netbox_prefix" "gh_lan" {
  prefix      = "10.0.0.0/24"
  status      = "active"
  description = "GH LAN - used for base infrastructure only."
}

resource "netbox_ip_address" "gh_opnsense_lan_gateway" {
  ip_address   = "10.0.0.1/24"
  description  = "GH LAN Gateway"
  interface_id = netbox_device_interface.opnsense_lan.id
  object_type  = "dcim.interface"
  status       = "active"
}
