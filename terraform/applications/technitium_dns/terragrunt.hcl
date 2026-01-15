include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "."
}

inputs = {
  loadbalancer_ip = include.env.locals.network.ips.technitium_dns
}
