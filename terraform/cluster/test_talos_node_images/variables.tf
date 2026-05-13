variable "nodes" {
  description = "The nodes"
  type = list(object({
    name       = string,
    ip_address = string,
    vm         = bool
  }))

  validation {
    condition     = length(var.nodes) == length(distinct([for n in var.nodes : n.name]))
    error_message = "Duplicate node names found in var.nodes — names must be unique."
  }

}
