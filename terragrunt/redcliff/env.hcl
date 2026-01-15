locals {
  cluster = "redcliff"
  env     = "redcliff"
  nodes = [
    {
      name            = "redcliff-node-1",
      ip_address      = "10.10.10.11",
      control_plane   = true
      storage_enabled = false
      vm              = true
    },
    {
      name            = "redcliff-node-2",
      ip_address      = "10.10.10.12",
      control_plane   = true
      storage_enabled = false
      vm              = true
    },
    {
      name            = "redcliff-node-3",
      ip_address      = "10.10.10.13",
      control_plane   = true
      storage_enabled = false
      vm              = false
    },
    {
      name            = "redcliff-node-4",
      ip_address      = "10.10.10.14",
      control_plane   = false
      storage_enabled = true
      vm              = false
    },
    {
      name            = "redcliff-node-5",
      ip_address      = "10.10.10.15",
      control_plane   = false
      storage_enabled = true
      vm              = false
    },
    {
      name            = "redcliff-node-6",
      ip_address      = "10.10.10.16",
      control_plane   = false
      storage_enabled = true
      vm              = false
    }
  ]

  network = {
    node_gateway             = "10.10.10.1"
    node_subnet_size         = "24"
    node_netmask              = "255.255.0.0"
    loadbalancer_ip_pool_cidr = "10.11.10.1/24"
    loadbalancer_bgp_asn      = 65555
    ips = {
      kubevip            = "10.10.10.10"
      ingress_controller = "10.11.10.11"
      monitoring         = "10.11.10.12"
      postgresql         = "10.11.10.32"
      technitium_dns     = "10.11.10.53"
    }
  }
}