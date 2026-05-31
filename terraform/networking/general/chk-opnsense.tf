resource "netbox_cluster" "chk_cluster" {
  cluster_type_id = netbox_cluster_type.proxmox.id
  name            = "chk-cluster"
  site_id         = netbox_site.chk.id
}


resource "netbox_virtual_machine" "chk_opnsense_01" {
  cluster_id = netbox_cluster.chk_cluster.id
  name       = "chk-opnsense-01"
}

resource "netbox_interface" "chk_opnsense_01_wan" {
  name               = "wan"
  virtual_machine_id = netbox_virtual_machine.chk_opnsense_01.id
}

resource "netbox_ip_address" "chk_opnsense_01_wan_address" {
  ip_address   = "192.168.0.35/24"
  description  = "CHK Opnsense WAN IP Address"
  interface_id = netbox_interface.chk_opnsense_01_wan.id
  object_type  = "virtualization.vminterface"
  status       = "active"
}
