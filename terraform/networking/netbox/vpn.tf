
resource "netbox_prefix" "wireguard_peering_prefix" {
  prefix      = "100.64.0.0/24"
  status      = "active"
  description = "Used for Wireguard peering between sites."
}

resource "netbox_ip_address" "gh_wireguard_tunnel_address" {
  ip_address   = "100.64.0.1/24"
  description  = "GH Wireguard Tunnel Address"
  interface_id = netbox_device_interface.opnsense_wan.id
  object_type  = "dcim.interface"
  status       = "active"
}

resource "netbox_ip_address" "chk_wireguard_tunnel_address" {
  ip_address   = "100.64.0.2/24"
  description  = "CHK Wireguard Tunnel Address"
  interface_id = netbox_interface.chk_opnsense_01_wan.id
  object_type  = "virtualization.vminterface"
  status       = "active"
}

resource "netbox_vpn_tunnel_group" "site_to_site_wireguard" {
  name = "Site-to-site Wireguard"
}


resource "netbox_vpn_tunnel" "site_to_site_wireguard" {
  name            = "Site-to-site Wireguard Tunnel"
  encapsulation   = "wireguard"
  status          = "active"
  tunnel_group_id = netbox_vpn_tunnel_group.site_to_site_wireguard.id
}


resource "netbox_vpn_tunnel_termination" "gh_opnsense" {
  role                = "peer"
  tunnel_id           = netbox_vpn_tunnel.site_to_site_wireguard.id
  device_interface_id = netbox_device_interface.opnsense_wan.id
}

resource "netbox_vpn_tunnel_termination" "vm" {
  role                         = "peer"
  tunnel_id                    = netbox_vpn_tunnel.site_to_site_wireguard.id
  virtual_machine_interface_id = netbox_interface.chk_opnsense_01_wan.id
}