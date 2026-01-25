variable "name" {
  description = "The name of the ingress resource."
  type        = string
}

variable "hostname" {
  description = "The hostname for the ingress resource."
  type        = string
}

variable "ip_address" {
  description = "The IP address for the ingress resource."
  type        = string
}

variable "port" {
  description = "The port for the ingress resource."
  type        = number
}

variable "portname" {
  description = "The name of the port for the ingress resource."
  type        = string
  default     = "http"
}

variable "extra-ingress-annotations" {
  description = "Extra annotations to apply to this ingress resource."
  default = {}
}

variable "local-only" {
  description = "Whether or not this endpoint is local access only"
  default = false
  type    = bool
}