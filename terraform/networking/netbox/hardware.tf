resource "netbox_device_role" "networking" {
  name      = "Networking"
  color_hex = "00a2ff"
}

## All devices will be given this manufacturer and device type, as I don't need to track them in this much detail.
resource "netbox_manufacturer" "custom" {
  name = "Custom"
}

resource "netbox_device_type" "opnsense_router" {
  model           = "Opnsense router"
  manufacturer_id = netbox_manufacturer.custom.id
}

resource "netbox_device_type" "managed_switch" {
  model           = "Managed switch"
  manufacturer_id = netbox_manufacturer.custom.id
}

resource "netbox_device_type" "unmanaged_switch" {
  model           = "Unmanaged switch"
  manufacturer_id = netbox_manufacturer.custom.id
}

resource "netbox_device_type" "proxmox_node" {
  model           = "Proxmox node"
  manufacturer_id = netbox_manufacturer.custom.id
}

resource "netbox_cluster_type" "proxmox" {
  name = "Proxmox"
}
resource "netbox_device" "opnsense" {
  name           = "gh-opnsense"
  device_type_id = netbox_device_type.opnsense_router.id
  role_id        = netbox_device_role.networking.id
  site_id        = netbox_site.gh.id
}

resource "netbox_device_interface" "opnsense_lan" {
  name      = "lan"
  device_id = netbox_device.opnsense.id
  type      = "1000base-t"
}

resource "netbox_device_interface" "opnsense_wan" {
  name      = "wan"
  device_id = netbox_device.opnsense.id
  type      = "1000base-t"
}