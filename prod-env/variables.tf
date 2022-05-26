variable "project_id" { }

variable "credentials_file" { }

variable "region" {
  default = "europe-west3"
}

variable "zone" {
  default = "europe-west3-b"
}

variable "zones" {
  type        = list(string)
  default = ["europe-west3-b","europe-west3-a"]
  description = "Network tags, provided as a list"
}

variable "network" {
  description = "network informations"
  type        = map(string)
  default     = {
    name    = "def",
    subnetName = "def",
    subnetIPRange = "def"
  }
  sensitive = false
}
variable "networktags" {
  type        = list(string)
  description = "Network tags, provided as a list"
}

variable "publicIp" {
  type    = bool
  default = false
}


variable "utilsproject" {
  description = "utils project details"
  type        = map(string)
  default     = {
    projectName    = "def",
    networkName    = "def"
  }
  sensitive = false
}
