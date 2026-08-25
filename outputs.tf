output "gateway_id" {
  description = "Composite ID of the Public Gateway, in `{zone}/{uuid}` form."
  value       = one(scaleway_vpc_public_gateway.this[*].id)
}

output "gateway_uuid" {
  description = "Bare UUID of the Public Gateway."
  value       = one([for id in scaleway_vpc_public_gateway.this[*].id : split("/", id)[1]])
}

output "egress_ip" {
  description = "Public IPv4 that masqueraded traffic appears to originate from. Allowlist this wherever an origin address must be pinned."
  value       = one(scaleway_vpc_public_gateway_ip.this[*].address)
}

output "egress_ip_cidr" {
  description = "Egress IP as a /32, ready to drop into an allowlist such as a Kapsule ACL."
  value       = one([for ip in scaleway_vpc_public_gateway_ip.this[*].address : "${ip}/32"])
}

output "ip_id" {
  description = "Composite ID of the flexible IP attached to the gateway."
  value       = local.ip_id
}

output "bastion_port" {
  description = "TCP port of the SSH bastion, when enabled."
  value       = var.bastion_enabled ? one(scaleway_vpc_public_gateway.this[*].bastion_port) : null
}

output "gateway_network_ids" {
  description = "Map of private network key to the composite ID of its gateway attachment."
  value       = { for k, gn in scaleway_vpc_gateway_network.this : k => gn.id }
}
