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
  # Обработка входящих правил: преобразуем все возможные варианты в унифицированный формат
  processed_ingress_rules = [
    for r in var.ingress_rules : {
      direction               = "ingress",
      ethertype               = lookup(r, "ethertype", can(regex(":", lookup(r, "remote_ip_prefix", ""))) ? "IPv6" : "IPv4")
      protocol                = lookup(r, "protocol", null) != "" ? lookup(r, "protocol", null) : ""
      port_range_min          = try(tonumber(lookup(r, "port", lookup(r, "port_range_min", null))), null)
      port_range_max          = try(tonumber(lookup(r, "port", lookup(r, "port_range_max", null))), null)
      description             = lookup(r, "description", null)
      region                  = lookup(r, "region", null)
      tenant_id               = lookup(r, "tenant_id", null)
      remote_address_group_id = lookup(r, "remote_address_group_id", null) != "" ? lookup(r, "remote_address_group_id", null) : null
      remote_group_id         = lookup(r, "remote_group_id", null) != "" ? lookup(r, "remote_group_id", null) : null
      remote_ip_prefix        = lookup(r, "remote_ip_prefix", null) != "" ? lookup(r, "remote_ip_prefix", null) : null
    }
  ]

  processed_egress_rules = [
    for r in var.egress_rules : {
      direction               = "egress",
      ethertype               = lookup(r, "ethertype", can(regex(":", lookup(r, "remote_ip_prefix", ""))) ? "IPv6" : "IPv4")
      protocol                = lookup(r, "protocol", null) != "" ? lookup(r, "protocol", null) : ""
      port_range_min          = try(tonumber(lookup(r, "port", lookup(r, "port_range_min", null))), null)
      port_range_max          = try(tonumber(lookup(r, "port", lookup(r, "port_range_max", null))), null)
      description             = lookup(r, "description", null)
      region                  = lookup(r, "region", null)
      tenant_id               = lookup(r, "tenant_id", null)
      remote_address_group_id = lookup(r, "remote_address_group_id", null) != "" ? lookup(r, "remote_address_group_id", null) : null
      remote_group_id         = lookup(r, "remote_group_id", null) != "" ? lookup(r, "remote_group_id", null) : null
      remote_ip_prefix        = lookup(r, "remote_ip_prefix", null) != "" ? lookup(r, "remote_ip_prefix", null) : null
    }
  ]

  # Combine all rules
  rules = concat(local.processed_ingress_rules, local.processed_egress_rules)
}

resource "openstack_networking_secgroup_rule_v2" "rules" {
  for_each = var.create ? { for idx, rule in local.rules : idx => rule } : {}

  region            = each.value.region != null ? each.value.region : var.region
  tenant_id         = each.value.tenant_id != null ? each.value.tenant_id : var.tenant_id
  security_group_id = local.this_sg_id
  direction         = each.value.direction
  ethertype         = each.value.ethertype
  protocol          = each.value.protocol
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  description       = each.value.description

  remote_address_group_id = each.value.remote_address_group_id

  remote_group_id = each.value.remote_address_group_id != null ? null : (
    each.value.remote_group_id == "@self"
    ? local.this_sg_id
    : each.value.remote_group_id
  )

  remote_ip_prefix = (
    each.value.remote_address_group_id != null || each.value.remote_group_id != null
    ? null
    : each.value.remote_ip_prefix
  )
}
