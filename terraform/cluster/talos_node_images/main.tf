locals {
  nodes = { for n in var.nodes : n.name => n if n.vm }
}

resource "talos_image_factory_schematic" "vm_schematic" {
  for_each = local.nodes
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = [
          "siderolabs/qemu-guest-agent"
        ]
      }
      extraKernelArgs = [
        "ip=${each.value.ip_address}::${var.network.node_gateway}:${var.network.node_netmask}::ens18:off",
      ]
    }
  })
}

resource "proxmox_download_file" "talos_installer" {
  for_each = local.nodes
  content_type = "iso"
  datastore_id = each.value.iso_storage
  node_name    = each.value.node
  file_name    = "talos-${each.key}-installer.iso"
  url          = "https://factory.talos.dev/image/${talos_image_factory_schematic.vm_schematic[each.key].id}/v1.13.0/metal-amd64.iso"
  overwrite    = false
}

output "image-ids" {
  value = { for k, v in proxmox_download_file.talos_installer : k => v.id }
}
