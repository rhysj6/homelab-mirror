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

variable "allowed_redirect_uris" {
    description = "List of allowed redirect URIs for the OAuth2 provider."
    type        = list(object({
        url           = string
        matching_mode = string
    }))
    default     = []
  
}