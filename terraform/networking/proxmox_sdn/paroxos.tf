resource "proxmox_sdn_vnet" "paroxos" {
  id    = "paroxos"
  zone  = proxmox_sdn_zone_evpn.main.id
  alias = "Parox - OS GH"
  tag   = 3010
}

resource "proxmox_sdn_subnet" "paroxos" {
  cidr    = "10.48.0.0/24"
  vnet    = proxmox_sdn_vnet.paroxos.id
  gateway = "10.48.0.1"
}

resource "netbox_prefix" "paroxos" {
  prefix      = proxmox_sdn_subnet.paroxos.cidr
  status      = "active"
  description = "GH paroxos"
  vrf_id      = data.netbox_vrf.this.id
}

import {
  id = "paroxos"
  to = proxmox_sdn_vnet.paroxos
}

import {
  id = "paroxos/Main-10.48.0.0-24"
  to = proxmox_sdn_subnet.paroxos
}
