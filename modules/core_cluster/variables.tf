variable "cluster_name" {
  description = "The name of the cluster (also infisical environment name)"
  type        = string
}

variable "cilium_loadbalancer_ip_pool_cidr" {
  description = "The CIDR block for the Cilium LoadBalancer IP Pool"
  type        = string
}

variable "ingress_controller_ip" {
  description = "The IP address of the Ingress Controller"
  type        = string
}

variable "number_of_nodes" {
  description = "The number of nodes in the cluster"
  type        = number
  default = 3
}