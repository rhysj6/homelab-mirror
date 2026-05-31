resource "netbox_rir" "internal" {
  name        = "Internal"
  description = "Internal RIR for private IP address management."
}

resource "netbox_aggregate" "private_ipv4" {
  prefix      = "10.0.0.0/24"
  rir_id      = netbox_rir.internal.id
  description = "Aggregate for private IPv4 addresses."
}

resource "netbox_aggregate" "chk_private_ipv4" {
  prefix      = "192.168.0.0/16"
  rir_id      = netbox_rir.internal.id
  description = "Aggregate for CHK private IPv4 addresses."
}


resource "netbox_asn" "gh_asn" {
  asn         = 65551
  rir_id      = netbox_rir.internal.id
  description = "GH opnsense ASN"
  comments    = "GH ASN for peering with internal networks."
}

resource "netbox_asn" "chk_asn" {
  asn         = 65450
  rir_id      = netbox_rir.internal.id
  description = "CHK opnsense ASN"
  comments    = "CHK ASN for peering with GH ASN."
}