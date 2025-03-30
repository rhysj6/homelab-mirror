module "dns" {
    source = "../../redcliff/modules/pihole"
    domain = data.infisical_secrets.bootstrap.secrets["domain"].value
    load_balancer_ip = "10.20.31.53"
    windows_domain = data.infisical_secrets.bootstrap.secrets["windows_domain"].value
}