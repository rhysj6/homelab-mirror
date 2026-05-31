resource "netbox_tag" "kubernetes" {
  name      = "Kubernetes"
  color_hex = "001eff"
}
resource "netbox_tag" "redcliff" {
  name      = "Redcliff"
  color_hex = "ff0000"
}
resource "netbox_tag" "test_k8s" {
  name      = "Test K8s"
  color_hex = "ff00f2"
}

resource "netbox_vlan" "redcliff" {
  name = "Redcliff"
  vid  = 40
  tags = [
    netbox_tag.kubernetes.name, 
    netbox_tag.redcliff.name
  ]
}
resource "netbox_prefix" "gh_redcliff" {
  prefix      = "10.10.10.0/24"
  status      = "active"
  description = "GH Redcliff - used for Redcliff kubernetes cluster nodes IPs."
  vlan_id     = netbox_vlan.redcliff.id
  tags = [
    netbox_tag.kubernetes.name,
    netbox_tag.redcliff.name
  ]
}

resource "netbox_ip_address" "gh_redcliff_gateway" {
  ip_address   = "10.10.10.1/24"
  description  = "GH Redcliff Gateway"
  interface_id = netbox_device_interface.opnsense_lan.id
  object_type  = "dcim.interface"
  status       = "active"
}

resource "netbox_vlan" "test_k8s" {
  name = "test_k8s"
  vid  = 41
  tags = [
    netbox_tag.kubernetes.name, 
    netbox_tag.test_k8s.name
  ]
}
resource "netbox_prefix" "gh_test_k8s" {
  prefix      = "10.10.20.0/24"
  status      = "active"
  description = "GH Test K8s - used for Test K8s kubernetes cluster nodes IPs."
  vlan_id     = netbox_vlan.test_k8s.id
  tags = [
    netbox_tag.kubernetes.name, 
    netbox_tag.test_k8s.name
  ]
}

resource "netbox_ip_address" "gh_test_k8s_gateway" {
  ip_address   = "10.10.20.1/24"
  description  = "GH Test K8s Gateway"
  interface_id = netbox_device_interface.opnsense_lan.id
  object_type  = "dcim.interface"
  status       = "active"
}
