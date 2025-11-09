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
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = local.control_plane_endpoints
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [talos_machine_configuration_apply.control_plane]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.control_plane_endpoints[0]
}


data "talos_cluster_health" "init_health" {
  depends_on = [talos_machine_configuration_apply.control_plane]

  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = local.control_plane_endpoints
  worker_nodes         = [for n in local.worker_nodes : n.ip_address]
  endpoints            = local.control_plane_endpoints
  skip_kubernetes_checks = true
}


resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [data.talos_cluster_health.init_health]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.control_plane_endpoints[0]
}


data "talos_cluster_health" "final_health" {
  depends_on = [data.talos_cluster_health.init_health, talos_cluster_kubeconfig.kubeconfig, helm_release.cilium, talos_machine_configuration_apply.worker]

  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = local.control_plane_endpoints
  worker_nodes         = [for n in local.worker_nodes : n.ip_address]
  endpoints            = local.control_plane_endpoints
}