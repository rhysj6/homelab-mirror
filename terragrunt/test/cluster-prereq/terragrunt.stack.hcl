unit "test_talos_nodes" {
  source = "${get_repo_root()}/terraform/cluster/test_talos_node_images"
  path   = "talos_node_images"
}