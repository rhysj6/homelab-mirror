module "core" {
    source = "../../../modules/core_cluster"
    cluster_name = "management"
    cilium_loadbalancer_ip_pool_cidr = "10.20.11.1/24"
    ingress_controller_ip = "10.20.11.11"
    number_of_nodes = 1
    cluster_node_ips = [
        "10.20.10.11"
    ]
}