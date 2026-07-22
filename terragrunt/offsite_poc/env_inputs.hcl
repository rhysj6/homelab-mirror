inputs = {
  cluster = "ospoc"
  env     = "ospoc"
  nodes = [
    {
      name            = "ospoc-node-1",
      ip_address      = "192.168.0.241",
      control_plane   = true
      storage_enabled = true
      vm              = true
      vmid            = 301
      iso_storage     = "ISO"
      storage         = "local-lvm"
      node            = "XENON"
    },
    {
      name            = "ospoc-node-2",
      ip_address      = "192.168.0.242",
      control_plane   = false
      storage_enabled = true
      vm              = true
      vmid            = 302
      iso_storage     = "ISO"
      storage         = "local-lvm"
      node            = "XENON"
    }
  ]

  network = {
    node_gateway             = "192.168.0.100"
    node_subnet_size         = "24"
    node_netmask              = "255.255.255.0"
    main_pod_cidr             = "10.49.0.0/17"
    native_routing_enabled    = true
    loadbalancer_ip_pool_cidr = "10.49.128.0/24"
    vmbridge                  = "vmbr0"
    node_dns                = "192.168.0.152"
    ips = {
      kubevip            = "192.168.0.240"
      ingress_controller = "10.49.128.11"
      monitoring         = "10.49.128.12"
    }

    bgp = { 
      cluster_asn = 65453
      peer_name   = "chk-opnsense-1"
      peer_ip     = "192.168.0.35"
      peer_asn    = 65450
    }
  }
}