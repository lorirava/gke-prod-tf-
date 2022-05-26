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

resource "google_compute_disk" "db2home-auth" {
  name  = "db2home-auth"
  type  = "pd-ssd"
  size = 220
  zone = var.zone
}

resource "google_compute_disk" "db2archive-auth" {
  name  = "db2archive-auth"
  type  = "pd-standard"
  size = 100
  zone = var.zone
}

resource "google_compute_disk" "db2home-live" {
  name  = "db2home-live"
  type  = "pd-ssd"
  size = 220
  zone = var.zone
}

resource "google_compute_disk" "db2archive-live" {
  name  = "db2archive-live"
  type  = "pd-standard"
  size = 100
  zone = var.zone
}

resource "google_compute_attached_disk" "default-auth" {
  disk     = google_compute_disk.db2home-auth.id
  instance = google_compute_instance.srvdb2prodauth.id
}
resource "google_compute_attached_disk" "db2archive-auth" {
  disk     = google_compute_disk.db2archive-auth.id
  instance = google_compute_instance.srvdb2prodauth.id
}
resource "google_compute_attached_disk" "default-live" {
  disk     = google_compute_disk.db2home-live.id
  instance = google_compute_instance.srvdb2prodlive.id
}
resource "google_compute_attached_disk" "db2archive-live" {
  disk     = google_compute_disk.db2archive-live.id
  instance = google_compute_instance.srvdb2prodlive.id
}

resource "google_compute_instance" "srvdb2prodauth" {
  project      = var.project_id # Replace this with your project ID in quotes
  zone         = var.zone
  name         = "srvdb2prodauth"
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
    network_ip         ="10.85.226.59"  

  }

  #network tag
  tags         = var.networktags
  
  lifecycle {
    ignore_changes = [attached_disk]
  }

}

resource "google_compute_instance" "srvdb2prodlive" {
  project      = var.project_id # Replace this with your project ID in quotes
  zone         = var.zone
  name         = "srvdb2prodlive"
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
    network_ip         ="10.85.226.60"  

  }

  #network tag
  tags         = var.networktags
  
  lifecycle {
    ignore_changes = [attached_disk]
  }

}

##FILESTORE
resource "google_filestore_instance" "filestore-nfs-utils" {
  name = "nfsutils"
  zone = var.zone
  tier = "PREMIUM"

  file_shares {
    capacity_gb = 1024
    name        = "nfsutils"
  }

  networks {
    network = var.network["name"]
    modes   = ["MODE_IPV4"]
  }
}


resource "google_iap_brand" "project_brand_1" {
  support_email     = "brand-cuba-prod-iac@brand-cuba-prod.iam.gserviceaccount.com"
  application_title = "Cloud IAP protected Application"
  project           = var.project_id
}