include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "proxmox" {
  path = find_in_parent_folders("proxmox.hcl")
}

include "env" {
  path   = find_in_parent_folders("env_inputs.hcl")
}
terraform {
  source = "."
}
