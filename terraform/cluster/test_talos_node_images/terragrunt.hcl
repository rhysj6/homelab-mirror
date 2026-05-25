include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "proxmox" {
  path = find_in_parent_folders("proxmox.hcl")
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}
terraform {
  source = "."
}

inputs = {
  nodes        = include.env.locals.nodes
}