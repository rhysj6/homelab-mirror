variable "cluster_name" {
  description = "The name of the Talos cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version to use for the cluster. Will automatically upgrade to this version if changed"
  type        = string
}

variable "talos_version" {
  description = "The Talos version to use for the cluster. Will not automatically upgrade to this version if changed, but will be used to validate configuration"
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

variable "network" {
  description = "Network configuration"
  type = object({
    node_gateway           = string,
    node_subnet_size       = string,
    native_routing_enabled = bool, # Disable this when initially setting up the cluster, then enable it after if you want to use native routing with Cilium.
    main_pod_cidr          = string
  })
}
