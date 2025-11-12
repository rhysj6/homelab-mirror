resource "proxmox_virtual_environment_vm" "node" {
  for_each    = local.vms
  name        = each.key
  description = "Test cluster node Managed by Terraform"
  tags        = ["kubernetes", "test-cluster"]

  node_name = each.value.host
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
    dedicated = 12288
  }

  cdrom {
    file_id   = proxmox_virtual_environment_download_file.talos_installer[each.key].id
    interface = "ide2"
  }

  disk {
    datastore_id = each.value.storage_datastore
    interface    = "scsi0"
    size         = 512
    file_format  = "qcow2"
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = 41
  }

  operating_system {
    type = "l26"
  }

  boot_order = ["scsi0", "ide2"]

}
