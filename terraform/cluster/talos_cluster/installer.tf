data "talos_image_factory_versions" "this" {
  filters = {
    stable_versions_only = true
  }
}

locals {
  latest = element(data.talos_image_factory_versions.this.talos_versions, length(data.talos_image_factory_versions.this.talos_versions) - 1)
}

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

output "latest_talos_version" {
  value = local.latest
}

output "node_images" {
  value = {
    for node in local.nodes :
    node.name => "factory.talos.dev/metal-installer/${talos_image_factory_schematic.machine[node.name].id}:${local.latest}"
  }
}