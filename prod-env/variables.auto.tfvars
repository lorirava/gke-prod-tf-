project_id                    = "brand-cuba-prod"
credentials_file           = "brand-cuba-prod-69eaa2e6ef68.json"

network = {
  name          = "cuba-prod-vpc"
  subnetName    = "cuba-prod-vpc-subnet"
  subnetIPRange = "10.85.226.0/26"
}

networktags = [
  "iap-firewall","pod-service-enable"
]

publicIp = true

utilsproject = {
  projectName    = "brand-cuba"
  networkName    = "cuba-utils-vpc"
}