#terraform {
#  required_providers {
#    google = {
#      source  = "hashicorp/google"
#      version = "3.5.0"
#    }
#  }
#}

provider "google" {
  //credentials = file(var.credentials_file)
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

### DB: VM and disks

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "3.3.0"

  project_id   = var.project_id
  network_name = var.network["name"]
  routing_mode = "REGIONAL"

  subnets = [
      {
          subnet_name           = var.network["subnetName"]
          subnet_ip             = var.network["subnetIPRange"]
          subnet_region         = var.region
      }
  ]
}

resource "google_compute_disk" "utils2" {
  name  = "utils2"
  type  = "pd-balanced"
  size = 500
  zone = var.zone
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.utils2.id
  instance = google_compute_instance.utils.id
}

resource "google_compute_disk" "utils3" {
  name  = "utils3"
  type  = "pd-balanced"
  size = 150
  zone = var.zone
}

resource "google_compute_attached_disk" "default2" {
  disk     = google_compute_disk.utils3.id
  instance = google_compute_instance.utils.id
}

resource "google_compute_address" "static" {
  name = "ipv4-utils-address"
}

resource "google_compute_firewall" "utils-firewall" {
  name    = "utils-firewall"
  network = var.network["name"]
  
  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges =["80.76.74.244/32","93.51.195.36/32","91.81.41.195/32"]
  target_tags     = ["utils-firewall"]
}


resource "google_compute_instance" "utils" {
  project      = var.project_id # Replace this with your project ID in quotes
  zone         = var.zone
  name         = "srvutils"
  machine_type = "n2-standard-2"
  boot_disk {
    auto_delete = false
    initialize_params {
      image = "rhel-cloud/rhel-8"
    }
  }
  network_interface {
    network            = var.network["name"]
    subnetwork         = var.network["subnetName"]
    //network_ip         = length(var.network_ip) > 0 ? var.network_ip : null
    network_ip         ="10.85.224.10"  

    ###!!!! TEMPORARY. It create a public IP
    access_config {
      nat_ip = google_compute_address.static.address
    }

  }

  #network tag
  tags         = var.networktags
  
  lifecycle {
    ignore_changes = [attached_disk]
  }

}


##PEERING
resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = "projects/${var.project_id}/global/networks/${var.network["name"]}"
  peer_network = "projects/${var.prodproject["projectName"]}/global/networks/${var.prodproject["networkName"]}"
}