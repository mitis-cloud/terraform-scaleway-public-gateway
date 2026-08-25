locals {
  enabled = var.create

  tags = [for k, v in var.tags : "${k}=${v}"]

  ip_id = var.create_ip ? one(scaleway_vpc_public_gateway_ip.this[*].id) : var.ip_id

  private_networks = local.enabled ? var.private_networks : {}
}

resource "scaleway_vpc_public_gateway_ip" "this" {
  count = local.enabled && var.create_ip ? 1 : 0

  project_id = var.project_id
  zone       = var.zone
  reverse    = var.ip_reverse
  tags       = local.tags
}

resource "scaleway_vpc_public_gateway" "this" {
  count = local.enabled ? 1 : 0

  name              = var.name
  type              = var.type
  project_id        = var.project_id
  zone              = var.zone
  ip_id             = local.ip_id
  bastion_enabled   = var.bastion_enabled
  bastion_port      = var.bastion_port
  enable_smtp       = var.enable_smtp
  allowed_ip_ranges = var.allowed_ip_ranges
  refresh_ssh_keys  = var.refresh_ssh_keys
  tags              = local.tags

  lifecycle {
    precondition {
      condition     = var.create_ip || var.ip_id != null
      error_message = "Set `ip_id` when `create_ip` is false, otherwise the gateway has no public address."
    }
  }
}

resource "scaleway_vpc_gateway_network" "this" {
  for_each = local.private_networks

  gateway_id         = scaleway_vpc_public_gateway.this[0].id
  private_network_id = each.value.private_network_id
  zone               = var.zone
  enable_masquerade  = each.value.enable_masquerade
  static_address     = each.value.static_address

  ipam_config {
    push_default_route = each.value.push_default_route
    ipam_ip_id         = each.value.ipam_ip_id
  }
}
