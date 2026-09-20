# Any none fully-IAC'd infrastructure will be here

resource "netbox_virtual_machine" "automator" {
  cluster_id   = netbox_cluster.gh_proxmox.id
  name         = "automator"
}

resource "netbox_interface" "automator" {
  name               = "eth0"
  virtual_machine_id = netbox_virtual_machine.automator.id
}

resource "netbox_ip_address" "automator" {
  ip_address   = "10.10.2.25/24"
  status       = "active"
  interface_id = netbox_interface.automator.id
  object_type = "virtualization.vminterface"
}

resource "netbox_virtual_machine" "paperless" {
  cluster_id   = netbox_cluster.gh_proxmox.id
  name         = "paperless"
}

resource "netbox_interface" "paperless" {
  name               = "eth0"
  virtual_machine_id = netbox_virtual_machine.paperless.id
}

resource "netbox_ip_address" "paperless" {
  ip_address   = "10.10.1.4/24"
  status       = "active"
  interface_id = netbox_interface.paperless.id
  object_type = "virtualization.vminterface"
}

resource "netbox_virtual_machine" "netbox" {
  cluster_id   = netbox_cluster.gh_proxmox.id
  name         = "netbox"
}

resource "netbox_interface" "netbox" {
  name               = "eth0"
  virtual_machine_id = netbox_virtual_machine.netbox.id
}

resource "netbox_ip_address" "netbox" {
  ip_address   = "10.10.2.166/24"
  status       = "active"
  interface_id = netbox_interface.netbox.id
  object_type = "virtualization.vminterface"
}

resource "netbox_virtual_machine" "actual_budget" {
  cluster_id   = netbox_cluster.gh_proxmox.id
  name         = "actualbudget"
}

resource "netbox_interface" "actual_budget" {
  name               = "eth0"
  virtual_machine_id = netbox_virtual_machine.actual_budget.id
}

resource "netbox_ip_address" "actual_budget" {
  ip_address   = "10.10.1.5/24"
  status       = "active"
  interface_id = netbox_interface.actual_budget.id
  object_type = "virtualization.vminterface"
}

resource "netbox_virtual_machine" "proxmox_backup_server" {
  cluster_id   = netbox_cluster.gh_proxmox.id
  name         = "proxmox_backup_server"
}

resource "netbox_interface" "proxmox_backup_server" {
  name               = "eth0"
  virtual_machine_id = netbox_virtual_machine.proxmox_backup_server.id
}

resource "netbox_ip_address" "proxmox_backup_server" {
  ip_address   = "10.0.0.25/24"
  status       = "active"
  interface_id = netbox_interface.proxmox_backup_server.id
  object_type = "virtualization.vminterface"
}

resource "netbox_virtual_machine" "home_assistant" {
  cluster_id   = netbox_cluster.gh_proxmox.id
  name         = "home_assistant"
}

resource "netbox_interface" "home_assistant_1" {
  name               = "enp0s18"
  virtual_machine_id = netbox_virtual_machine.home_assistant.id
}

resource "netbox_ip_address" "home_assistant_1" {
  ip_address   = "10.10.1.10/24"
  status       = "active"
  interface_id = netbox_interface.home_assistant_1.id
  object_type = "virtualization.vminterface"
}

resource "netbox_interface" "home_assistant_2" {
  name               = "enp0s19"
  virtual_machine_id = netbox_virtual_machine.home_assistant.id
}

resource "netbox_ip_address" "home_assistant_2" {
  ip_address   = "10.1.4.19/24"
  status       = "active"
  interface_id = netbox_interface.home_assistant_2.id
  object_type = "virtualization.vminterface"
}
