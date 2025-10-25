include "root" {
  path = find_in_parent_folders("root.hcl")

}

terraform {
  source = "${get_repo_root()}/terraform/cluster/talos_cluster"
}


inputs = {
  cluster_name = "test"
  nodes = [
    {
      name            = "test-node-1",
      ip_address      = "10.20.30.11",
      control_plane   = true
      storage_enabled = true
      vm              = true
    },
    {
      name            = "test-node-2",
      ip_address      = "10.20.30.12",
      control_plane   = true
      storage_enabled = true
      vm              = true
    },
    {
      name            = "test-node-3",
      ip_address      = "10.20.30.13",
      control_plane   = true
      storage_enabled = true
      vm              = true
    }
  ]
  kubevip = "10.20.30.10"
}