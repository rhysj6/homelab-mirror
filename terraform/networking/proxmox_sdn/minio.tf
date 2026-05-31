# Deprecated infra, needs replacing, but is in isolated vnet for now.

resource "proxmox_sdn_vnet" "minio" {
  id    = "minio"
  zone  = proxmox_sdn_zone_evpn.main.id
  alias = "Minio"
  tag   = 1412
}

resource "proxmox_sdn_subnet" "minio" {
  cidr    = "10.10.0.136/29"
  vnet    = proxmox_sdn_vnet.minio.id
  gateway = "10.10.0.137"
}

resource "netbox_prefix" "minio" {
  prefix      = proxmox_sdn_subnet.minio.cidr
  status      = "active"
  description = "GH Minio"
  vrf_id      = data.netbox_vrf.this.id
}

import {
  id = "minio"
  to = proxmox_sdn_vnet.minio
}

import {
  id = "minio/Main-10.10.0.136-29"
  to = proxmox_sdn_subnet.minio
}
