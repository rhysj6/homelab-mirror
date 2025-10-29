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
  cluster_name = include.env.locals.cluster
  nodes        = include.env.locals.nodes
  kubevip      = include.env.locals.network.ips.kubevip
}