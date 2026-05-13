resource "talos_image_factory_schematic" "machine" {
  for_each = local.nodes
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = concat(
            each.value.storage_enabled ? [
              "siderolabs/iscsi-tools",
              "siderolabs/util-linux-tools",
            ] : [],
            each.value.vm ? ["siderolabs/qemu-guest-agent"] : []
          )
        }
      }
    }
  )
}

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
      interface    = each.value.vm ? "ens18" : "eno1"
    }),
    
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/metal-installer/${talos_image_factory_schematic.machine[each.key].id}:${var.talos_version}"
        }
      }
    })
  ])
  talos_version = var.talos_version
  kubernetes_version = var.kubernetes_version
}

output "node_images" {
  value = {
    for node in local.nodes :
    node.name => "factory.talos.dev/metal-installer/${talos_image_factory_schematic.machine[node.name].id}:${var.talos_version}"
  }
}

