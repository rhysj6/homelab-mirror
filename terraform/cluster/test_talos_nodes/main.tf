resource "proxmox_virtual_environment_vm" "node" {
  for_each    = local.vms
  name        = each.key
  description = "Test cluster node Managed by Terraform"
  tags        = ["kubernetes", "test-cluster"]

  node_name = "clifton"
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
    file_id   = "BX-2TB-1:iso/talos-${each.key}-installer.iso"
    interface = "ide2"
  }

  disk {
    datastore_id = each.value.storage_datastore
    interface    = "scsi0"
    size         = 512
    file_format  = "qcow2"
  }

  network_device {
    bridge      = "testk8s"
  }

  operating_system {
    type = "l26"
  }

  boot_order = ["scsi0", "ide2"]

}
