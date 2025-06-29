variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "domain" {
  description = "The domain name that most resources will be created under."
  type        = string
}

variable "number_of_replicas" {
  description = "The number of nodes in the cluster"
  type        = number
  default     = 2
}

variable "name" {
  description = "The name of the postgres cluster"
  type        = string
}

variable "namespace" {
  description = "The namespace of the postgres cluster"
  type        = string
}

variable "volume_size" {
  description = "The size of the volume to use for the postgres cluster"
  type        = number
  default     = 2
}

variable "external_clusters" {
  description = "A list of external clusters for use in replication and imports"
  type = list(object({
    name = string
    connectionParameters = object({
      host   = string
      user   = string
      dbname = string
    })
    password = object({
      name = string
      key  = string
    })
  }))
  default = []
}