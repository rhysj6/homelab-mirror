variable "cluster" {
  description = "Cluster name"
  type        = string
}

variable "nodes" {
  description = "The nodes"
  type = list(object({
    name        = string,
    ip_address  = string,
    vm          = bool
    node        = string
    vmid        = number
    iso_storage = string
    storage     = string
  }))

  validation {
    condition     = length(var.nodes) == length(distinct([for n in var.nodes : n.name]))
    error_message = "Duplicate node names found in var.nodes — names must be unique."
  }

}

variable "network" {
  description = "Network config"
  type = object({
    vmbridge     = string
  })
}
