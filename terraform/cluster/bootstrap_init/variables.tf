variable "cluster" {
  description = "The name of the cluster"
  type        = string
}

variable "network" {
  description = "Network configuration"
  type = object({
    loadbalancer_ip_pool_cidr = string,
    loadbalancer_bgp_asn     = number,
    ips = object({
      ingress_controller = string,
      monitoring         = string,
    }),
  })
}

variable "nodes" {
  description = "The nodes"
  type = list(object({
    ip_address      = string,
    storage_enabled = bool
  }))
}
