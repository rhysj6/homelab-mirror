resource "netbox_site" "gh" {
  name      = "GH"
  facility  = "Onsite Homelab"
  status    = "active"
}

resource "netbox_site" "chk" {
  name      = "CHK"
  facility  = "Offsite Homelab"
  status    = "active"
}