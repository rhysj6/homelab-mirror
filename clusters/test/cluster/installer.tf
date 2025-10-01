data "talos_image_factory_versions" "this" {
  filters = {
    stable_versions_only = true
  }
}

locals {
  latest = element(data.talos_image_factory_versions.this.talos_versions, length(data.talos_image_factory_versions.this.talos_versions) - 1)
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = local.latest
  filters = {
    names = [
      "qemu-guest-agent",
      "iscsi-tools",
      "util-linux-tools"
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

locals {
  image = "factory.talos.dev/metal-installer/${talos_image_factory_schematic.this.id}:${local.latest}"
}

output "latest_talos_version" {
  value = local.latest
}

output "talos_image" {
  value = local.image
}