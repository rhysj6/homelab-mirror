module "semaphore" {
  source       = "../../module"
  domain       = var.domain  
}

variable "domain" {
  description = "The main domain name"
  type        = string
}