output "security_group_id" {
  description = "The ID of the security group"
  value       = try(values(openstack_networking_secgroup_v2.this)[0].id, "")
}

output "security_group_name" {
  description = "The name of the security group"
  value       = try(values(openstack_networking_secgroup_v2.this)[0].name, "")
}

output "security_group_tenant_id" {
  description = "The tenant ID of the security group"
  value       = try(values(openstack_networking_secgroup_v2.this)[0].tenant_id, "")
}

output "security_group_all_tags" {
  description = "The collection of tags assigned on the security group, which have been explicitly and implicitly added"
  value       = try(values(openstack_networking_secgroup_v2.this)[0].all_tags, [])
}
