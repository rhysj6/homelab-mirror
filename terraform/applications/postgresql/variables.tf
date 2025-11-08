variable "env" {
  description = "The environment name"
  type        = string
}

variable "loadbalancer_ip" {
  description = "IP Address to expose the cluster on"
  type        = string
}
