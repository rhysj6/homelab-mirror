resource "proxmox_sdn_vnet" "personal" {
  id    = "personal"
  zone  = proxmox_sdn_zone_evpn.main.id
  alias = "Personal Util"
  tag   = 30
}

resource "proxmox_sdn_subnet" "personal" {
  cidr    = "10.10.1.0/24"
  vnet    = proxmox_sdn_vnet.personal.id
  gateway = "10.10.1.1"
}

resource "netbox_prefix" "personal" {
  prefix      = proxmox_sdn_subnet.personal.cidr
  status      = "active"
  description = "GH personal"
  vrf_id      = data.netbox_vrf.this.id
}

import {
  id = "personal"
  to = proxmox_sdn_vnet.personal
}

import {
  id = "personal/Main-10.10.1.0-24"
  to = proxmox_sdn_subnet.personal
}
