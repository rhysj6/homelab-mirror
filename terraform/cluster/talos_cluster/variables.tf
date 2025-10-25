variable "cluster_name" {
  description = "The name of the Talos cluster"
  type        = string
}

variable "kubevip" {
  description = "The VIP address for the Kubernetes API server"
  type        = string
}

variable "nodes" {
  description = "The nodes"
  type = list(object({
    name            = string,
    ip_address      = string,
    control_plane   = bool,
    storage_enabled = bool
    vm              = bool
  }))

  validation {
    condition     = length(var.nodes) == length(distinct([for n in var.nodes : n.name]))
    error_message = "Duplicate node names found in var.nodes — names must be unique."
  }

}


