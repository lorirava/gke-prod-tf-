
#module "network" {
#  source  = "terraform-google-modules/network/google"
#  version = "3.3.0"
#
#  project_id   = var.project_id
#  network_name = var.network["name"]
#  routing_mode = "REGIONAL"
#
#  subnets = [
#      {
#          subnet_name           = var.network["subnetName"]
#          subnet_ip             = var.network["subnetIPRange"]
#          subnet_region         = var.region
#      }
#  ]
#}


resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = var.network["subnetName"]
  ip_cidr_range = var.network["subnetIPRange"]
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_network" "vpc_network" {
  name = var.network["name"]
  project = var.project_id
  routing_mode = "REGIONAL"
  auto_create_subnetworks = false
}
##
resource "google_compute_firewall" "iap-firewall" {
  name    = "iap-firewall"
  network = var.network["name"]
  
  allow {
    protocol      = "tcp"
  }

  source_ranges =["35.235.240.0/20"]
  target_tags     = ["iap-firewall"]
}

### Identy Aware Proxy to access

resource "google_project_service" "project_service" {
  project = var.project_id
  service = "iap.googleapis.com"
}

#commentato perchè dopo essere stato creato continua ad andare in errore
#resource "google_iap_brand" "project_brand_1" {
#  support_email     = "brand-cuba-prod-iac@brand-cuba-prod.iam.gserviceaccount.com"
#  application_title = "Cloud IAP protected Application"
#  project           = var.project_id
#}

resource "google_iap_client" "project_client" {
  display_name = "cuba-iap-client"
  brand        =  google_iap_brand.project_brand_1.name
}


##CloudNat setup

resource "google_compute_router" "router" {
  name    = "myrouter"
  region  = var.region
  network = var.network["name"]

  #bgp {
  #  asn = 64514
  #}
}

resource "google_compute_address" "address" {
  count  = 1
  name   = "nat-manual-ip-${count.index}"
  region = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region

  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.address.*.self_link

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

##PEERING
resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = "projects/${var.project_id}/global/networks/${var.network["name"]}"
  peer_network = "projects/${var.utilsproject["projectName"]}/global/networks/${var.utilsproject["networkName"]}"
}

