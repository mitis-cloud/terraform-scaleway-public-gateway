terraform {
  required_version = ">= 1.5.0"

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.81, < 3.0"
    }
  }
}

provider "scaleway" {
  region = "fr-par"
  zone   = "fr-par-1"
}

variable "private_network_id" {
  type        = string
  description = "Composite ID of an existing private network. Create one with mitis-cloud/vpc/scaleway."
}

module "gateway" {
  source = "../../"

  name            = "example-gw"
  zone            = "fr-par-1"
  type            = "VPC-GW-S"
  bastion_enabled = true

  private_networks = {
    main = {
      private_network_id = var.private_network_id
      enable_masquerade  = true
      push_default_route = true
    }
  }

  tags = {
    environment = "example"
  }
}

output "egress_ip_cidr" {
  description = "Allowlist this on anything the private network must reach."
  value       = module.gateway.egress_ip_cidr
}
