resource "kubernetes_manifest" "cilium_loadbalancer_ip_pool" {
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "main-pool"
    }
    spec = {
      blocks = [
        {
          cidr = var.network.loadbalancer_ip_pool_cidr
        }
      ]
      allowFirstLastIPs = "No"
    }
  }
}

# resource "kubernetes_manifest" "cilium_l2_announcement_policy" {
#   count = var.cilium_use_bgp ? 0 : 1
#   manifest = {
#     apiVersion = "cilium.io/v2"
#     kind       = "CiliumL2AnnouncementPolicy"
#     metadata = {
#       name = "default-policy"
#     }
#     spec = {
#       externalIPs     = true
#       loadBalancerIPs = true
#     }
#   }
# }

resource "kubernetes_manifest" "cilium_bgp_cluster_config" {
  # count = var.cilium_use_bgp ? 1 : 0
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumBGPClusterConfig"
    metadata = {
      name = "cilium-bgp"
    }
    spec = {
      bgpInstances = [
        {
          name     = "default"
          localASN = var.network.bgp.cluster_asn
          peers = [
            {
              name        = var.network.bgp.peer_name
              peerASN     = var.network.bgp.peer_asn
              peerAddress = var.network.bgp.peer_ip
              peerConfigRef = {
                name = "default-peer"
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "cilium_bgp_peer_config" {
  # count = var.cilium_use_bgp ? 1 : 0
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumBGPPeerConfig"
    metadata = {
      name = "default-peer"
    }
    spec = {
      families = [
        {
          afi  = "ipv4"
          safi = "unicast"
          advertisements = {
            matchLabels = {
              advertise = "bgp"
            }
          }
        },
        {
          afi  = "ipv6"
          safi = "unicast"
          advertisements = {
            matchLabels = {
              advertise = "bgp"
            }
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "cilium_bgp_advertisement" {
  # count = var.cilium_use_bgp ? 1 : 0
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumBGPAdvertisement"
    metadata = {
      name = "bgp-advertisements"
      labels = {
        advertise = "bgp"
      }
    }
    spec = {
      advertisements = [
        {
          advertisementType = "Service"
          service = {
            addresses = [
              "LoadBalancerIP",
              "ExternalIP"
            ]
          }
          selector = {
            matchExpressions = [
              {
                key      = "bgp"
                operator = "NotIn"
                values   = ["false"]
              }
            ]
          }
        },
        {
          advertisementType = "CiliumPodIPPool"
          selector = {
            matchExpressions = [
              {
                key      = "bgp"
                operator = "NotIn"
                values   = ["false"]
              }
            ]
          }
        }
      ]
    }
  }
}