variable "env" {
  description = "The environment name"
  type        = string
}

variable "databases" {
  description = "List of databases to create"
  type        = set(string)
  default     = []
}
