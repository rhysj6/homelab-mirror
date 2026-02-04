variable "loki_url" {
  description = "The URL for the Loki instance"
  type        = string
}

variable "loki_password" {
  description = "The password for Loki basic auth"
  type        = string
  sensitive   = true
}
