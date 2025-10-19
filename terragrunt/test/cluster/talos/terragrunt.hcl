include "root" {
  path = find_in_parent_folders("root.hcl")

}

terraform {
  source = "${get_repo_root()}/terraform/cluster/talos_cluster"
}


inputs = {
  cluster_name = "test"
  node_1_ip    = "10.20.30.11"
  node_2_ip    = "10.20.30.12"
  node_3_ip    = "10.20.30.13"
  kubevip      = "10.20.30.10"
}