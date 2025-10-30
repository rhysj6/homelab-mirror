unit "test_talos_nodes" {
  source = "${get_repo_root()}/terraform/cluster/test_talos_nodes"
  path   = "talos_nodes"
}

unit "talos_cluster" {
  source = "${get_repo_root()}/terraform/cluster/talos_cluster"
  path   = "talos_cluster"
}

unit "bootstrap_init" {
  source = "${get_repo_root()}/terraform/cluster/bootstrap_init"
  path   = "bootstrap_init"
}

unit "bootstrap_final" {
  source = "${get_repo_root()}/terraform/cluster/bootstrap_final"
  path   = "bootstrap_final"
}