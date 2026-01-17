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

dependencies {
  paths = ["../technitium_dns"]
}

inputs = {
  dns_server_ip = include.env.locals.network.ips.technitium_dns
}
