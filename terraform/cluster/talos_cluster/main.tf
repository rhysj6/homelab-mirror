locals {
  nodes = { for n in var.nodes : n.name => n }
  control_plane_nodes = {
    for name, node in local.nodes : name => node
    if node.control_plane == true
  }
  worker_nodes = {
    for name, node in local.nodes : name => node
    if node.control_plane == false
  }

  control_plane_endpoints = [for n in local.control_plane_nodes : n.ip_address]
}


resource "talos_machine_secrets" "machine_secrets" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = local.control_plane_endpoints
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [talos_machine_configuration_apply.control_plane, talos_machine_configuration_apply.worker]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.control_plane_endpoints[0]
}

resource "time_sleep" "kubevip_wait" {
  depends_on = [talos_machine_bootstrap.bootstrap]
  create_duration = "59s"
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [time_sleep.kubevip_wait]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.control_plane_endpoints[0]
}
