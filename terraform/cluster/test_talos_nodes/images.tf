data "talos_image_factory_versions" "this" {
  filters = {
    stable_versions_only = true
  }
}

locals {
  latest = element(data.talos_image_factory_versions.this.talos_versions, length(data.talos_image_factory_versions.this.talos_versions) - 1)
}

resource "talos_image_factory_schematic" "vm_schematic" {
  for_each = local.vms
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = [
          "siderolabs/qemu-guest-agent"
        ]
      }
      extraKernelArgs = [
        "ip=${each.value.ip_address}::10.10.20.1:255.255.255.0::ens18:off",
      ]
    }
  })
}

resource "proxmox_virtual_environment_download_file" "talos_installer" {
  provider     = proxmox.grh
  for_each = local.vms
  content_type = "iso"
  datastore_id = "${each.value.host == "clifton" ? "BX-2TB-1" : "Datastore_2"}"
  node_name    = each.value.host
  file_name    = "talos-${each.key}-installer.iso"
  url          = "https://factory.talos.dev/image/${talos_image_factory_schematic.vm_schematic[each.key].id}/${local.latest}/metal-amd64.iso"
  overwrite    = false
}
