locals {
  nodes = { for n in var.nodes : n.name => n if n.vm }
}

resource "proxmox_virtual_environment_vm" "node" {
  for_each    = local.nodes
  name        = each.key
  description = "${var.cluster} cluster node Managed by Terraform"
  tags        = ["kubernetes", "${var.cluster}-cluster"]

  node_name = each.value.node
  vm_id     = each.value.vmid

  agent {
    enabled = true
  }

  startup {
    order    = "3"
    up_delay = "60"
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8096
  }

  cdrom {
    file_id   = "${each.value.iso_storage}:iso/talos-${each.key}-installer.iso"
    interface = "ide2"
  }

  disk {
    datastore_id = each.value.storage
    interface    = "scsi0"
    size         = 512
    file_format  = "qcow2"
  }

  network_device {
    bridge      = var.network.vmbridge
  }

  operating_system {
    type = "l26"
  }

  boot_order = ["scsi0", "ide2"]

}
