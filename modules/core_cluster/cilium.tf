resource "kubernetes_manifest" "cilium_loadbalancer_ip_pool" {
  count = local.cilium_crd_exists ? 1 : 0 ## Only create the IP pool if the CRD exists (will require a re-run if the CRD is created by the Helm release)
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "main-pool"
    }
    spec = {
      blocks = [
        {
          cidr = var.cilium_loadbalancer_ip_pool_cidr
        }
      ]
      allowFirstLastIPs = "No"
    }
  }
}

resource "kubernetes_manifest" "cilium_l2_announcement_policy" {
  count = (local.cilium_crd_exists && var.cilium_use_bgp ? 0 : 1) ## Only create the policy if the CRD exists (will require a re-run if the CRD is created by the Helm release) and BGP is not used
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"
    metadata = {
      name = "default-policy"
    }
    spec = {
      externalIPs     = true
      loadBalancerIPs = true
    }
  }
}

resource "kubernetes_manifest" "cilium_bgp_cluster_config" {
  count = (local.cilium_crd_exists && var.cilium_use_bgp ? 1 : 0) ## Only create the config if the CRD exists (will require a re-run if the CRD is created by the Helm release) and BGP is used
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumBGPClusterConfig"
    metadata = {
      name = "cilium-bgp"
    }
    spec = {
      bgpInstances = [
        {
          name     = "management-1"
          localASN = var.cilium_bgp_asn
          peers = [
            {
              name        = "opnsense"
              peerASN     = 65551
              peerAddress = "10.0.0.1"
              peerConfigRef = {
                name = "opnsense-peer"
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "cilium_bgp_peer_config" {
  count = (local.cilium_crd_exists && var.cilium_use_bgp ? 1 : 0) ## Only create the config if the CRD exists (will require a re-run if the CRD is created by the Helm release) and BGP is used
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumBGPPeerConfig"
    metadata = {
      name = "opnsense-peer"
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
  count = (local.cilium_crd_exists && var.cilium_use_bgp ? 1 : 0) ## Only create the config if the CRD exists (will require a re-run if the CRD is created by the Helm release) and BGP is used
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
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
        }
      ]
    }
  }
}