include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../talos"]
}

terraform {
  source = "${get_repo_root()}/modules/cluster/bootstrap_init"
}


inputs = {
  cluster_name                     = "test"
  cilium_loadbalancer_ip_pool_cidr = "10.21.30.1/24"
  ingress_controller_ip            = "10.21.30.11"
  monitoring_ip                    = "10.21.30.12"
  cilium_bgp_asn                   = 65553
  cluster_node_ips = [
    "10.20.30.11",
    "10.20.30.12",
    "10.20.30.13"
  ]
}
