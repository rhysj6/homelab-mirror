resource "proxmox_virtual_environment_vm" "backup_server" {
  vm_id       = 302
  name        = "backup-server"
  description = "Open media vault and proxmox backup server \nManaged by Terraform"
  node_name   = local.node_name

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.10.2.5/24"
        gateway = "10.10.2.1"
      }
    }

    user_account {
      username = "rhysj6"
      keys     = local.github_ssh_keys
    }
  }

  disk {
    datastore_id = "MX-2TB-1"
    import_from  = proxmox_download_file.backup_server_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 64
  }


  disk {
    datastore_id = "MX-2TB-1"
    interface    = "virtio1"
    iothread     = true
    discard      = "on"
    size         = 1000
  }

  agent {
    enabled = true
    timeout = "15m"
    trim    = true
    type    = "virtio"
  }

  # disk { # TODO: add this mid-migration
  #   datastore_id = ""
  #   path_in_datastore  = "/dev/path/to/block/device"
  #   file_format = "raw"
  # }

  network_device {
    bridge = "temple"
  }
}

resource "proxmox_download_file" "backup_server_image" {
  content_type = "import"
  datastore_id = "BX-2TB-1"
  node_name    = local.node_name
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
  file_name    = "debian-13-generic-amd64.qcow2"
}

resource "netbox_virtual_machine" "backup_server" {
  cluster_id = data.netbox_cluster.gh_proxmox.id
  name       = "backup-server"
}

resource "netbox_interface" "backup_server" {
  name               = "eth0"
  virtual_machine_id = netbox_virtual_machine.backup_server.id
}

resource "netbox_ip_address" "backup_server" {
  ip_address   = "10.10.2.5/24"
  status       = "active"
  interface_id = netbox_interface.backup_server.id
  object_type  = "virtualization.vminterface"
}
