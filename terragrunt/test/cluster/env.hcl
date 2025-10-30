locals {
  cluster = "test"
  nodes = [
    {
      name            = "test-node-1",
      ip_address      = "10.10.20.11",
      control_plane   = true
      storage_enabled = true
      vm              = true
    },
    {
      name            = "test-node-2",
      ip_address      = "10.10.20.12",
      control_plane   = false
      storage_enabled = true
      vm              = true
    },
    {
      name            = "test-node-3",
      ip_address      = "10.10.20.13",
      control_plane   = false
      storage_enabled = true
      vm              = true
    }
  ]

  network = {
    node_gateway             = "10.10.20.1"
    node_subnet_size         = "24"
    node_netmask              = "255.255.0.0"
    loadbalancer_ip_pool_cidr = "10.11.20.1/24"
    loadbalancer_bgp_asn      = 65553
    ips = {
      kubevip            = "10.10.20.10"
      ingress_controller = "10.11.20.11"
      monitoring         = "10.11.20.12"
    }
  }
}