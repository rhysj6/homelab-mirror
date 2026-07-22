inputs = {
  cluster = "test"
  env     = "test"
  nodes = [
    {
      name            = "test-node-1",
      ip_address      = "10.10.20.11",
      control_plane   = true
      storage_enabled = true
      vm              = true
      vmid            = 3001
      iso_storage     = "BX-2TB-1"
      storage         = "MX-2TB-1"
      node            = "clifton"
    },
    {
      name            = "test-node-2",
      ip_address      = "10.10.20.12",
      control_plane   = false
      storage_enabled = true
      vm              = true
      vmid            = 3002
      iso_storage     = "BX-2TB-1"
      storage         = "BX-2TB-1"
      node            = "clifton"
    }
  ]

  network = {
    node_gateway             = "10.10.20.1"
    node_subnet_size         = "24"
    node_netmask              = "255.255.255.0"
    main_pod_cidr             = "10.41.0.0/17"
    native_routing_enabled    = true
    loadbalancer_ip_pool_cidr = "10.11.20.1/24"
    vmbridge                  = "testk8s"
    ips = {
      kubevip            = "10.10.20.10"
      ingress_controller = "10.11.20.11"
      monitoring         = "10.11.20.12"
      postgresql         = "10.11.20.32"
    }

    bgp = { 
      cluster_asn = 65553
      peer_name   = "opnsense"
      peer_ip     = "10.0.0.1"
      peer_asn    = 65551
    }
  }
}