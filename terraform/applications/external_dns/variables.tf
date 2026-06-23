variable "network" {
  description = "The network configuration"
  type        = object({
    ips = object({
      technitium_dns = string
    })
  })
}
