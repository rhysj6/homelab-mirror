variable "domain" {
  description = "The main domain name"
  type        = string
}

variable "load_balancer_ip" {
  description = "The load balancer IP address"
  type        = string
  default = "10.20.1.53"
}

variable "windows_domain" {
  description = "The Windows domain name for conditional forwarding"
  type        = string
}