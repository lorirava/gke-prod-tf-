project_id                    = "brand-cuba"
credentials_file           = "brand-cuba-utils-iac-6d7af079722b.json"

network = {
  name          = "cuba-utils-vpc"
  subnetName    = "cuba-utils-vpc-subnet"
  subnetIPRange = "10.85.224.0/26"
}

networktags = [
  "utils-firewall","pod-service-enable"
]

publicIp = true


prodproject = {
  projectName    = "brand-cuba-prod"
  networkName    = "cuba-prod-vpc"
}