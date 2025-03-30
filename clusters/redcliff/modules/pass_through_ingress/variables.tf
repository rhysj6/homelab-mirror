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