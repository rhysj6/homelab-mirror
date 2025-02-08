
variable "infisical" {
  type = object({
    host       = string
    machine_id = string
    token      = string
  })
}

variable "authentik_host" {
  type = string
}