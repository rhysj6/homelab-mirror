
resource "talos_machine_secrets" "machine_secrets" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [local.node_1_ip, local.node_2_ip, local.node_3_ip]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.cp_01_config_apply,
    talos_machine_configuration_apply.cp_02_config_apply,
    talos_machine_configuration_apply.cp_03_config_apply
  ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.node_1_ip
}

# data "talos_cluster_health" "health" {
#   depends_on           = [ 
#     talos_machine_configuration_apply.cp_01_config_apply,
#     talos_machine_configuration_apply.cp_02_config_apply,
#     talos_machine_configuration_apply.cp_03_config_apply
#     ]
#   client_configuration = data.talos_client_configuration.talosconfig.client_configuration
#   control_plane_nodes  = [ local.node_1_ip, local.node_2_ip, local.node_3_ip ]
#   endpoints            = data.talos_client_configuration.talosconfig.endpoints
# }

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [
    talos_machine_bootstrap.bootstrap,
    #    data.talos_cluster_health.health
  ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.node_1_ip
}

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}
