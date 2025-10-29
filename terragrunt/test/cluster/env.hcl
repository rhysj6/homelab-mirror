locals {
  cluster = "test"
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

  network = {
    gateway                   = "10.20.0.1"
    node_netmask              = "255.255.0.0"
    vlan_id                   = 40
    loadbalancer_ip_pool_cidr = "10.21.30.1/24"
    loadbalancer_bgp_asn      = 65553
    ips = {
      kubevip            = "10.20.30.10"
      ingress_controller = "10.21.30.11"
      monitoring         = "10.21.30.12"
    }
  }
}