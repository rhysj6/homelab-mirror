
data "talos_machine_configuration" "this" {
  for_each         = local.nodes
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.kubevip}:6443"
  machine_type     = each.value.control_plane ? "controlplane" : "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  config_patches = [
    templatefile("${path.module}/patches/main.yml.tftpl",{
      storage_enabled = each.value.storage_enabled
    }),
    each.value.control_plane ? file("${path.module}/patches/control-plane.yml") : "",
    each.value.storage_enabled ? file("${path.module}/patches/longhorn.yml") : "",
    templatefile("${path.module}/patches/network.yml.tftpl", {
      ip       = each.value.ip_address,
      hostname = each.key,
      vip      = var.kubevip,
      nodetype = each.value.control_plane ? "controlplane" : "worker"
    }),
    yamlencode({
      machine = {
        install = {
          image = local.image
        }
      }
    })
  ]
  talos_version = local.latest
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each                    = local.control_plane_nodes
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = each.value.ip_address
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = local.worker_nodes
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = each.value.ip_address
  depends_on                  = [talos_machine_configuration_apply.control_plane]
}

