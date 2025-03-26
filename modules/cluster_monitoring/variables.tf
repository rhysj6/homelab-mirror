variable "cluster_domain" {
  description = "The domain of the cluster"
  type        = string
}

variable "cluster_node_ips" {
  description = "List of cluster node IPs"
  type        = list(string)
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "authentik_url" {
  description = "The URL of the Authentik instance"
  type        = string
}