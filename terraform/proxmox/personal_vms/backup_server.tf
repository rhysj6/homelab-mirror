resource "proxmox_virtual_environment_vm" "backup_server" {
  vm_id     = 302
  name      = "backup-server"
  description = "Open media vault and proxmox backup server \nManaged by Terraform"
  node_name = local.node_name

  cpu {
    cores = 4
    type = "host"
  }

  memory {
    dedicated = 4096
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.0.23/24"
        gateway = "10.0.0.1"
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

  # disk { # TODO: add this mid-migration
  #   datastore_id = ""
  #   path_in_datastore  = "/dev/path/to/block/device"
  #   file_format = "raw"
  # }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_download_file" "backup_server_image" {
  content_type = "import"
  datastore_id = "BX-2TB-1"
  node_name    = local.node_name
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
  file_name    = "debian-13-generic-amd64.qcow2"
}

