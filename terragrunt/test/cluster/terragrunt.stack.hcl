unit "talos" {
  source = "${get_repo_root()}/terraform/cluster/talos_cluster"
  path   = "talos"
}

unit "bootstrap_init" {
  source = "${get_repo_root()}/terraform/cluster/bootstrap_init"
  path   = "bootstrap_init"
}

unit "bootstrap_final" {
  source = "${get_repo_root()}/terraform/cluster/bootstrap_final"
  path   = "bootstrap_final"
}