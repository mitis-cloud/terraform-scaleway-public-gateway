variable "create" {
  type        = bool
  description = "Whether to create any resources."
  default     = true
}

variable "name" {
  type        = string
  description = "Name of the Public Gateway."
  default     = null
}

variable "zone" {
  type        = string
  description = "Availability zone. Public Gateways are zonal even though VPCs and private networks are regional. Defaults to the provider's zone when null."
  default     = null
}

variable "project_id" {
  type        = string
  description = "Scaleway Project ID. Defaults to the provider's project when null."
  default     = null
}

variable "type" {
  type        = string
  description = "Gateway offer. VPC-GW-S is the smallest and is sufficient for NAT egress; VPC-GW-XL is offered only in fr-par and nl-ams."
  default     = "VPC-GW-S"
}

variable "create_ip" {
  type        = bool
  description = "Allocate a flexible IP for the gateway. Set false and supply `ip_id` to reuse an address, which keeps the egress IP stable across gateway replacement."
  default     = true
}

variable "ip_id" {
  type        = string
  description = "Existing flexible IP to attach, used when `create_ip` is false."
  default     = null
}

variable "ip_reverse" {
  type        = string
  description = "Reverse DNS for the allocated IP."
  default     = null
}

variable "bastion_enabled" {
  type        = bool
  description = "Expose the SSH bastion. Scaleway's documented route for reaching instances that have no public IP."
  default     = false
}

variable "bastion_port" {
  type        = number
  description = "TCP port for the SSH bastion."
  default     = 61000
}

variable "enable_smtp" {
  type        = bool
  description = "Permit outbound SMTP through the gateway. Scaleway blocks SMTP by default to limit abuse."
  default     = false
}

variable "allowed_ip_ranges" {
  type        = list(string)
  description = "CIDRs permitted to reach the gateway's public services, such as the bastion. Empty means Scaleway's default."
  default     = []
}

variable "refresh_ssh_keys" {
  type        = string
  description = "Change this value to trigger a refresh of the SSH keys the bastion accepts."
  default     = null
}

variable "private_networks" {
  type = map(object({
    private_network_id = string
    enable_masquerade  = optional(bool, true)
    push_default_route = optional(bool, true)
    ipam_ip_id         = optional(string)
    static_address     = optional(string)
  }))
  description = <<-EOT
    Private networks to attach, keyed by short name.

    `enable_masquerade` NATs private traffic behind the gateway's public IP, giving
    every attached resource a single stable egress address.

    `push_default_route` advertises the gateway as the default route. Instances and
    Kapsule pools created with no public IP have no other egress path, so this must
    be true for them to reach the internet.

    A private network accepts only one gateway, so egress for everything attached is
    concentrated in this gateway's zone.
  EOT
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every resource. Rendered as `key=value` strings, since Scaleway tags are a list rather than a map."
  default     = {}
}
