
# Third-party vnets and subnets will all belong in this range
resource "netbox_prefix" "third_party" {
  prefix      = "10.48.0.0/16"
  status      = "active"
  description = "Third party"
}


resource "netbox_prefix" "vpn_clients" {
  prefix      = "10.2.0.0/16"
  status      = "active"
  description = "VPN Clients"
  is_pool = true
}

resource "netbox_prefix" "wg_vpn_clients" {
  prefix      = "10.2.0.0/24"
  status      = "active"
  description = "Wireguard VPN Clients"
  is_pool = true
}

resource "netbox_prefix" "pod_ip_pools" {
  prefix      = "10.40.0.0/14"
  status      = "active"
  description = "Pod IP Pools"
  is_pool = true
}

resource "netbox_prefix" "k8s_lb_ip_pools" {
  prefix      = "10.11.0.0/16"
  status      = "active"
  description = "Kubernetes Loadbalancer IP Pools"
  is_pool = true
}

