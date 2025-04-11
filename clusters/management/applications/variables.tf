
variable "domain" {
  description = "The domain name that most resources will be created under."
  type        = string
}

locals {
  authentik_host = "hl.${var.domain}"
}