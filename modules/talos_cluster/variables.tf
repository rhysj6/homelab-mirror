variable "cluster_name" {
  description = "The name of the Talos cluster"
  type        = string
}

variable "kubevip" {
  description = "The VIP address for the Kubernetes API server"
  type        = string
}

variable "node_1_ip" {
  description = "The IP address of the first control plane node"
  type        = string
}

variable "node_2_ip" {
  description = "The IP address of the second control plane node"
  type        = string
}

variable "node_3_ip" {
  description = "The IP address of the third control plane node"
  type        = string
}