variable "network" {
  description = "The network configuration"
  type        = object({
    ips = object({
      technitium_dns = string
    })
  })
}

variable "env" {
  description = "The environment name"
  type        = string
}