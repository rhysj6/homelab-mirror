include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

dependencies {
  paths = ["../talos_cluster"]
}

terraform {
  source = "."
}

inputs = {
  cluster_name                     = include.env.locals.cluster
  cilium_loadbalancer_ip_pool_cidr = include.env.locals.cilium_loadbalancer_ip_pool_cidr
  ingress_controller_ip            = include.env.locals.ips.ingress_controller
  monitoring_ip                    = include.env.locals.ips.monitoring
  cilium_bgp_asn                   = include.env.locals.cilium_bgp_asn
  cluster_node_ips                 = [for node in include.env.locals.nodes : node.ip_address]
}
