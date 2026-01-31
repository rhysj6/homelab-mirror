variable "name" {
  description = "The name of the application."
  type        = string
}

variable "slug" {
  description = "The slug for the application."
  type        = string
}

variable "url" {
  description = "The URL for the application."
  type        = string
}

variable "group" {
  description = "The group to which the application belongs."
  type        = string
}

variable "allowed_group" {
  description = "Allowed group to access the application."
  type        = string
  default     = ""
}

variable "secure_access" {
  description = "Enable secure access policy. Requires MFA."
  type        = bool
  default     = false
}

variable "local_only_access" {
    description = "Whether to restrict access to local network only."
    type        = bool
    default     = false
}

variable "allowed_redirect_uris" {
  description = "List of allowed redirect URIs for the OAuth2 provider."
  type = list(object({
    url           = string
    matching_mode = string
  }))
  default = []

}