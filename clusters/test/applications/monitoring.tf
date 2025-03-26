
module "monitoring" {
  source = "../../../modules/cluster_monitoring"
  cluster_domain = local.cluster_domain
  cluster_node_ips = [
    "10.20.30.11",
    "10.20.30.12",
    "10.20.30.13"
  ]
    cluster_name = "test"
    authentik_url = local.authentik_domain
}