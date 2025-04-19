module "cluster" {
  source       = "../../../modules/downstream_cluster"
  cluster_name = "test"
  domain = var.domain
}

variable "domain" {
  description = "The domain name that most resources will be created under."
  type        = string
}