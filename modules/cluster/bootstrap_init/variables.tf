variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "cilium_loadbalancer_ip_pool_cidr" {
  description = "The CIDR block for the Cilium LoadBalancer IP Pool"
  type        = string
}

variable "cilium_use_bgp" {
  description = "Whether to use BGP for Cilium"
  type        = bool
  default     = true
}

variable "cilium_bgp_asn" {
  description = "The ASN for the Cilium BGP configuration"
  type        = number
  default     = 65555
}

variable "ingress_controller_ip" {
  description = "The IP address of the Ingress Controller"
  type        = string
}

variable "monitoring_ip" {
  description = "The IP address of the monitoring service"
  type        = string
}

variable "number_of_nodes" {
  description = "The number of nodes in the cluster"
  type        = number
  default     = 3
}

variable "cluster_node_ips" {
  description = "List of cluster node IPs"
  type        = list(string)
}