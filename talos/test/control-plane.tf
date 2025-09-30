
data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name     = local.cluster_name
  cluster_endpoint = "https://${local.node_1_ip}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  config_patches = [
    for f in fileset(path.module, "patches/*.yml") : file("${path.module}/${f}")
  ]
  talos_version = "v1.11"
}

resource "talos_machine_configuration_apply" "cp_01_config_apply" {
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  node                        = local.node_1_ip
  config_patches = [
    templatefile("${path.module}/patches/node_specific/network.yml.tmpl", {
      ip = local.node_1_ip,
      hostname = "test-node-1"
    })
  ]
}


resource "talos_machine_configuration_apply" "cp_02_config_apply" {
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  node                        = local.node_2_ip
  config_patches = [
    templatefile("${path.module}/patches/node_specific/network.yml.tmpl", {
      ip = local.node_2_ip,
      hostname = "test-node-2"
    })
  ]
}



resource "talos_machine_configuration_apply" "cp_03_config_apply" {
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  node                        = local.node_3_ip
  config_patches = [
    templatefile("${path.module}/patches/node_specific/network.yml.tmpl", {
      ip = local.node_3_ip,
      hostname = "test-node-3"
    })
  ]
}