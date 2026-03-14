include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

dependency "nodes" {
  config_path  = "../talos_nodes"
  skip_outputs = true
  enabled      = include.env.locals.cluster == "test"
}

terraform {
  source = "."
}

inputs = {
  cluster_name = include.env.locals.cluster
  talos_version = include.env.locals.talos_version
  kubernetes_version = include.env.locals.kubernetes_version
  nodes        = include.env.locals.nodes
  kubevip      = include.env.locals.network.ips.kubevip
  network      = include.env.locals.network
}