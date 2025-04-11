variable "domain" {
  description = "The domain name that most resources will be created under."
  type        = string
}

variable "windows_domain" {
  description = "The Windows domain name that some resources will be created under."
  type        = string
}

variable "cloudflare_email" {
  description = "The email address for Cloudflare"
  type        = string
}

variable "cloudflare_api_key" {
  description = "The API key for Cloudflare"
  type        = string
  sensitive   = true
}