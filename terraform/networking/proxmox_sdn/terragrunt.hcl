include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "proxmox" {
  path = find_in_parent_folders("proxmox.hcl")
}

terraform {
  source = "."
}

dependencies {
  paths = ["../general"]
}