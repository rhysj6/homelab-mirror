variable "domain" {
  description = "The domain name that most resources will be created under."
  type        = string
}

variable "secondary_domain" {
  description = "The secondary domain name that some resources will be created under."
  type        = string
}

variable "windows_domain" {
  description = "The Windows domain name that some resources will be created under."
  type        = string
}