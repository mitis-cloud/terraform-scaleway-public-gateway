# terraform-scaleway-public-gateway

Creates a Scaleway Public Gateway, its flexible IP, and its attachments to one or more
private networks.

This is what gives resources without public IPs a route to the internet, and what gives
them a **single stable egress address** you can allowlist elsewhere.

## Usage

```hcl
module "gateway" {
  source  = "mitis-cloud/public-gateway/scaleway"
  version = "~> 1.0"

  name = "platform-gw"
  zone = "fr-par-1"

  private_networks = {
    main = {
      private_network_id = module.vpc.private_network_ids["main"]
      enable_masquerade  = true
      push_default_route = true
    }
  }
}
```

## Why you probably want this

**`push_default_route` is load-bearing.** Instances and Kapsule pools created with no
public IP have no other path off the private network. Without a gateway advertising the
default route they cannot pull images, reach package mirrors, or call any external API.

**`enable_masquerade` gives you a pinnable origin IP.** Everything behind the gateway
egresses from one address, so you can allowlist it on a Kapsule ACL, a partner API, or a
database firewall. `egress_ip_cidr` emits it pre-formatted as a `/32`.

**It relieves the public-IP quota.** Scaleway allows 50 Instance IPs per Organization by
default. In Kapsule's default isolation mode every node consumes one, so a few
autoscaling pools will exhaust it. Running nodes with `public_ip_disabled` behind a
gateway removes that ceiling and the per-IP charge.

## Trade-offs to make deliberately

**A private network accepts exactly one gateway.** All egress for everything attached is
concentrated in this gateway's zone. If that zone fails, every attached resource loses
internet access — in *every* zone. Isolation buys you a concentrated failure mode; the
choice is real, so make it knowingly.

**Reuse the IP across replacements.** Set `create_ip = false` and pass `ip_id` to a
separately-managed `scaleway_vpc_public_gateway_ip` so the egress address survives
gateway recreation and your allowlists stay valid.

**SMTP is blocked by default.** Set `enable_smtp` if outbound mail must traverse the
gateway.

## Examples

- [complete](examples/complete) — gateway with bastion, fronting a VPC private network.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| scaleway | >= 2.81, < 3.0 |

## Providers

| Name | Version |
|------|---------|
| scaleway | >= 2.81, < 3.0 |

## Resources

| Name | Type |
|------|------|
| [scaleway_vpc_gateway_network.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_gateway_network) | resource |
| [scaleway_vpc_public_gateway.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway) | resource |
| [scaleway_vpc_public_gateway_ip.this](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/vpc_public_gateway_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_ip\_ranges | CIDRs permitted to reach the gateway's public services, such as the bastion.<br/><br/>Empty leaves the attribute unset so Scaleway's own default applies. Sending an<br/>explicit empty list would instead clear the default `0.0.0.0/0` rule and lock<br/>the bastion down, which is rarely what an unset variable is meant to express. | `list(string)` | `[]` | no |
| bastion\_enabled | Expose the SSH bastion. Scaleway's documented route for reaching instances that have no public IP. | `bool` | `false` | no |
| bastion\_port | TCP port for the SSH bastion. | `number` | `61000` | no |
| create | Whether to create any resources. | `bool` | `true` | no |
| create\_ip | Allocate a flexible IP for the gateway. Set false and supply `ip_id` to reuse an address, which keeps the egress IP stable across gateway replacement. | `bool` | `true` | no |
| enable\_smtp | Permit outbound SMTP through the gateway. Scaleway blocks SMTP by default to limit abuse. | `bool` | `false` | no |
| ip\_id | Existing flexible IP to attach, used when `create_ip` is false. | `string` | `null` | no |
| ip\_reverse | Reverse DNS for the allocated IP. | `string` | `null` | no |
| name | Name of the Public Gateway. | `string` | `null` | no |
| private\_networks | Private networks to attach, keyed by short name.<br/><br/>`enable_masquerade` NATs private traffic behind the gateway's public IP, giving<br/>every attached resource a single stable egress address.<br/><br/>`push_default_route` advertises the gateway as the default route. Instances and<br/>Kapsule pools created with no public IP have no other egress path, so this must<br/>be true for them to reach the internet.<br/><br/>A private network accepts only one gateway, so egress for everything attached is<br/>concentrated in this gateway's zone. | <pre>map(object({<br/>    private_network_id = string<br/>    enable_masquerade  = optional(bool, true)<br/>    push_default_route = optional(bool, true)<br/>    ipam_ip_id         = optional(string)<br/>    static_address     = optional(string)<br/>  }))</pre> | `{}` | no |
| project\_id | Scaleway Project ID. Defaults to the provider's project when null. | `string` | `null` | no |
| refresh\_ssh\_keys | Change this value to trigger a refresh of the SSH keys the bastion accepts. | `string` | `null` | no |
| tags | Tags applied to every resource. Rendered as `key=value` strings, since Scaleway tags are a list rather than a map. | `map(string)` | `{}` | no |
| type | Gateway offer. VPC-GW-S is the smallest and is sufficient for NAT egress; VPC-GW-XL is offered only in fr-par and nl-ams. | `string` | `"VPC-GW-S"` | no |
| zone | Availability zone. Public Gateways are zonal even though VPCs and private networks are regional. Defaults to the provider's zone when null. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| bastion\_port | TCP port of the SSH bastion, when enabled. |
| egress\_ip | Public IPv4 that masqueraded traffic appears to originate from. Allowlist this wherever an origin address must be pinned. |
| egress\_ip\_cidr | Egress IP as a /32, ready to drop into an allowlist such as a Kapsule ACL. |
| gateway\_id | Composite ID of the Public Gateway, in `{zone}/{uuid}` form. |
| gateway\_network\_ids | Map of private network key to the composite ID of its gateway attachment. |
| gateway\_uuid | Bare UUID of the Public Gateway. |
| ip\_id | Composite ID of the flexible IP attached to the gateway. |
<!-- END_TF_DOCS -->

## License

Apache 2.0. See [LICENSE](LICENSE).
