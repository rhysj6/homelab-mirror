variable "application_name" {
  description = "The name of the application."
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
