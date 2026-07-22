variable "nodes" {
  description = "The nodes"
  type = list(object({
    name        = string,
    ip_address  = string,
    vm          = bool
    node        = string
    iso_storage = string
  }))

  validation {
    condition     = length(var.nodes) == length(distinct([for n in var.nodes : n.name]))
    error_message = "Duplicate node names found in var.nodes — names must be unique."
  }

}

variable "network" {
  description = "Network config"
  type = object({
    node_gateway = string
    node_netmask = string
  })
}