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