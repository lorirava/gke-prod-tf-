##GCP Module used for VPN HA Setup
#https://github.com/terraform-google-modules/terraform-google-vpn/blob/v2.0.0/modules/vpn_ha/main.tf
#ATTENCTION! VPN could works fine, but maybe you need to open firewall route to connect VMs using VPN

module "vpn_ha-1" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "~> 1.3.0"
  
  project_id  = var.project_id
  region  = var.region
  network         = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/networks/${var.network["name"]}"
  name            = "net1-to-net-2"
  peer_gcp_gateway = module.vpn_ha-2.self_link
  router_asn = 64514
  router_advertise_config = {
    groups = ["ALL_SUBNETS"]
    ip_ranges = {
      "10.89.118.200/29" = "fileStore network"
    }
     mode      = "CUSTOM"
   }

  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.1"
        asn     = 64513
      }
      #bgp_peer_options  = null
      bgp_peer_options = {
        advertise_groups    = ["ALL_SUBNETS"]
        advertise_ip_ranges = {
          "10.89.118.200/29" = "fileStore network"
        }
        advertise_mode      = "CUSTOM"
        route_priority = 100
      }
      bgp_session_range = "169.254.1.2/30"
      ike_version       = 2
      vpn_gateway_interface = 0
      peer_external_gateway_interface = null
      shared_secret     = ""
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.1"
        asn     = 64513
      }
      #bgp_peer_options  = null
      bgp_peer_options = {
        advertise_groups    = ["all_subnets"]
        advertise_ip_ranges = {
          "10.89.118.200/29" = "fileStore network"
        }
        advertise_mode      = "CUSTOM"
        route_priority = 100
      }
      bgp_session_range = "169.254.2.2/30"
      ike_version       = 2
      vpn_gateway_interface = 1
      peer_external_gateway_interface = null
      shared_secret     = ""
    }
  }
}

module "vpn_ha-2" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "~> 1.3.0"
  project_id  = var.utilsproject["projectName"]
  region  = var.region
  network         = "https://www.googleapis.com/compute/v1/projects/${var.utilsproject["projectName"]}/global/networks/${var.utilsproject["networkName"]}"
  name            = "net2-to-net1"
  router_asn = 64513
  #router_advertise_config = {
  #  groups = null
  #  ip_ranges = {
  #    range = "10.89.118.200/29"
  #  }
  #  mode      = "CUSTOM"
  #}
  peer_gcp_gateway = module.vpn_ha-1.self_link
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.2"
        asn     = 64514
      }
      bgp_peer_options  = null
      bgp_session_range = "169.254.1.1/30"
      ike_version       = 2
      vpn_gateway_interface = 0
      peer_external_gateway_interface = null
      shared_secret     = module.vpn_ha-1.random_secret
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.2"
        asn     = 64514
      }
      bgp_peer_options  = null
      bgp_session_range = "169.254.2.1/30"
      ike_version       = 2
      vpn_gateway_interface = 1
      peer_external_gateway_interface = null
      shared_secret     = module.vpn_ha-1.random_secret
    }
  }
}