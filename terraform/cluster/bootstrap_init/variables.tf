variable "cluster" {
  description = "The name of the cluster"
  type        = string
}

variable "network" {
  description = "Network configuration"
  type = object({
    loadbalancer_ip_pool_cidr = string,
    ips = object({
      ingress_controller = string,
      monitoring         = string,
    }),
    bgp = object({ 
      cluster_asn = number
      peer_name   = string
      peer_ip     = string
      peer_asn    = number
    })
  })
}

variable "nodes" {
  description = "The nodes"
  type = list(object({
    ip_address      = string,
    storage_enabled = bool
  }))
}
