
data "talos_machine_configuration" "this" {
  for_each         = local.nodes
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.kubevip}:6443"
  machine_type     = each.value.control_plane ? "controlplane" : "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  docs             = true
  examples         = true
  config_patches = flatten([
    templatefile("${path.module}/patches/main.yml.tftpl", {
      storage_enabled = each.value.storage_enabled,
      control_plane   = each.value.control_plane
    }),

    templatefile("${path.module}/patches/custom_ca_certs.yml.tftpl", {
      custom_ca_cert = yamlencode(data.infisical_secrets.common.secrets.trusted_cert_auths.value)
    }),

    each.value.storage_enabled ? [for file in fileset("${path.module}/patches/longhorn", "*.yml") : file("${path.module}/patches/longhorn/${file}")] : [],

    templatefile("${path.module}/patches/network.yml.tftpl", {
      ip          = each.value.ip_address,
      gateway     = var.network.node_gateway,
      subnet_size = var.network.node_subnet_size,
      hostname    = each.key,
      vip         = var.kubevip,
      nodetype    = each.value.control_plane ? "controlplane" : "worker"
    }),
    
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/metal-installer/${talos_image_factory_schematic.machine[each.key].id}:${local.latest}"
        }
      }
    })
  ])
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

