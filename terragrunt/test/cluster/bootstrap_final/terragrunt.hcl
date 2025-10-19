include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../talos", "../bootstrap_init"]
}

terraform {
  source = "${get_repo_root()}/modules/cluster/bootstrap_final"
}


inputs = {
  cluster_name = "test"
}