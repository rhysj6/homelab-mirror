resource "netbox_tag" "client" {
  name      = "Client"
  color_hex = "40ff00"
}

resource "netbox_vlan" "client_main" {
  name = "Client Main"
  vid  = 21
  tags = [
    netbox_tag.client.name
  ]
}

resource "netbox_prefix" "gh_client_main" {
  prefix      = "10.1.1.0/24"
  status      = "active"
  description = "GH Client Main - used for client infrastructure."
  vlan_id     = netbox_vlan.client_main.id
  tags = [
    netbox_tag.client.name
  ]
}

resource "netbox_ip_address" "gh_client_main_gateway" {
  ip_address   = "10.1.1.1/24"
  description  = "GH Client Main Gateway"
  interface_id = netbox_device_interface.opnsense_lan.id
  object_type  = "dcim.interface"
  status       = "active"
}

resource "netbox_vlan" "client_iot" {
  name = "Client IOT"
  vid  = 24
  tags = [
    netbox_tag.client.name
  ]
}
resource "netbox_prefix" "gh_client_iot" {
  prefix      = "10.1.4.0/24"
  status      = "active"
  description = "GH Client IOT - used for client infrastructure."
  vlan_id     = netbox_vlan.client_iot.id
  tags = [
    netbox_tag.client.name
  ]
}

resource "netbox_ip_address" "gh_client_iot_gateway" {
  ip_address   = "10.1.4.1/24"
  description  = "GH Client IOT Gateway"
  interface_id = netbox_device_interface.opnsense_lan.id
  object_type  = "dcim.interface"
  status       = "active"
}
