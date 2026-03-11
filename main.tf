resource "random_id" "this" {
  keepers = {
    name_prefix = var.name_prefix
  }
  byte_length = 8
}

##################################
# Create Security Group
##################################
resource "openstack_networking_secgroup_v2" "this" {
  for_each = var.create ? { "id" = 1 } : {}

  name        = local.this_sg_name
  description = var.description
  region      = var.region
  tenant_id   = var.tenant_id

  tags                 = var.tags
  delete_default_rules = var.delete_default_rules
  stateful             = var.stateful

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  this_sg_id   = try(openstack_networking_secgroup_v2.this["id"].id, "")
  this_sg_name = var.use_name_prefix ? (var.name_prefix == "" ? "${random_id.this.hex}-${var.name}" : "${var.name_prefix}-${var.name}") : var.name
}

######################
# Security group rules
######################
locals {
  # Add ethertype based on the presence of ':' in remote_ip_prefix
  processed_ingress_rules = [
    for r in var.ingress_rules : merge(
      r,
      {
        direction = "ingress",
        ethertype = lookup(r, "ethertype", can(regex(":", lookup(r, "remote_ip_prefix", ""))) ? "IPv6" : "IPv4")
      }
    )
  ]

  processed_egress_rules = [
    for r in var.egress_rules : merge(
      r,
      {
        direction = "egress",
        ethertype = lookup(r, "ethertype", can(regex(":", lookup(r, "remote_ip_prefix", ""))) ? "IPv6" : "IPv4")
      }
    )
  ]

  # Combine all rules
  rules = concat(local.processed_ingress_rules, local.processed_egress_rules)
}

resource "openstack_networking_secgroup_rule_v2" "rules" {
  for_each = var.create ? { for idx, rule in local.rules : idx => rule } : {}

  region            = lookup(each.value, "region", var.region)
  tenant_id         = lookup(each.value, "tenant_id", var.tenant_id)
  security_group_id = local.this_sg_id
  direction         = each.value.direction
  ethertype         = each.value.ethertype
  protocol          = lookup(each.value, "protocol", null)
  port_range_min    = lookup(each.value, "port", lookup(each.value, "port_range_min", null))
  port_range_max    = lookup(each.value, "port", lookup(each.value, "port_range_max", null))
  description       = lookup(each.value, "description", null)

  remote_address_group_id = lookup(each.value, "remote_address_group_id", null)

  remote_group_id = lookup(each.value, "remote_address_group_id", null) != null ? null : (
    lookup(each.value, "remote_group_id", null) == "@self"
    ? local.this_sg_id
    : lookup(each.value, "remote_group_id", null)
  )

  remote_ip_prefix = (
    lookup(each.value, "remote_address_group_id", null) == null &&
    lookup(each.value, "remote_group_id", null) == null
    ? lookup(each.value, "remote_ip_prefix", null)
    : null
  )
}
