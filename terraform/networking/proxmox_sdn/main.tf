data "netbox_asn" "proxmox_evpn_asn" {
  tag = "proxmox-evpn"
}

data "netbox_vrf" "this" {
  name = "Proxmox EVPN VRF"
}
resource "proxmox_sdn_controller_evpn" "main" {
  id  = "gh"
  asn = data.netbox_asn.proxmox_evpn_asn.asn
  peers = [ ## TODO: These should be pulled from Netbox, but for now I'm hardcoding them here.
    "10.0.0.20",
    "10.0.0.19",
    "192.168.0.172"
  ]
}

data "proxmox_virtual_environment_nodes" "nodes" {}

resource "proxmox_sdn_zone_evpn" "main" {
  id = "Main"
  nodes = data.proxmox_virtual_environment_nodes.nodes.names
  controller = proxmox_sdn_controller_evpn.main.id
  vrf_vxlan  = 10000

  advertise_subnets          = true
  disable_arp_nd_suppression = false
  exit_nodes_local_routing   = false
  exit_nodes = data.proxmox_virtual_environment_nodes.nodes.names
  mtu = 1362

  ipam = "pve"
}
