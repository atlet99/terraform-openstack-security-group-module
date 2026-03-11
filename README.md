# Terraform OpenStack Security Group Module

Terraform module which creates security groups on OpenStack.

## Features

- Supports creation of security groups with dynamic names and tags.
- Allows defining stateful or stateless security groups.
- Supports custom ingress and egress rules with detailed configurations.
- Automatically handles IPv4/IPv6 rules based on the provided IP prefixes.

## Requirements

- `Terraform >= 1.5.0`
- `Terraform OpenStack Provider ~> 3.0.0`
- `Terraform Random Provider >= 3.6.3`

## Usage

### Basic Example

```hcl
module "security_group" {
  source = "github.com/atlet99/openstack-tf-security-group-module?ref=v1.0.0"

  name                 = "my-security-group"
  name_prefix          = "project"
  use_name_prefix      = true
  description          = "Security group for my project"
  tags                 = ["tag1", "tag2"]
  delete_default_rules = true
  stateful             = true
  region               = "main"

  ingress_rules = [
    {
      protocol         = "tcp"
      port             = 22
      remote_ip_prefix = "0.0.0.0/0"
      description      = "Allow SSH access"
    },
    {
      protocol         = "icmp"
      remote_ip_prefix = "::/0"
      description      = "Allow ICMP over IPv6"
    }
  ]

  egress_rules = [
    {
      protocol         = "tcp"
      port             = 80
      remote_ip_prefix = "0.0.0.0/0"
      description      = "Allow HTTP traffic"
    },
    {
      protocol         = "tcp"
      port             = 443
      remote_ip_prefix = "0.0.0.0/0"
      description      = "Allow HTTPS traffic"
    }
  ]
}
```

## Outputs

After applying this module, you can retrieve the following outputs:
```hcl
output "security_group_id" {
  value = module.security_group.security_group_id
}

output "security_group_name" {
  value = module.security_group.security_group_name
}
```

## Inputs

### Security Group Configuration:

| Name                | Description                                           | Type        | Default                |
|---------------------|-------------------------------------------------------|-------------|------------------------|
| create              | Whether to creater the security group and its rules   | bool        | true                   |
| name                | Name of the security group                            | string      | N/A                    |
| name_prefix         | Prefix to prepend to the security group name          | string      | ""                     |
| use_name_prefix     | Whether to use the name prefix                        | bool        | false                  |
| description         | Description of the security group                     | string      | "Managed by Terraform" |
| tags                | Tags to assign to the security group                  | set(string) | []                     |
| delete_default_rule | Whether to delete default rules in the security group | bool        | false                  |
| stateful            | Whether the security group is stateful                | bool        | true                   |
| region              | OpenStack region                                      | string      | ""                     |

### Rule Configuration:

| Name         | Description                                    | Type      | Default |
|--------------|------------------------------------------------|-----------|---------|
| ingress_rule | List of ingress rules (see example for format) | list(map) | []      |
| egress_rule  | List of egress rules (see example for format)  | list(map) | []      |

### Outputs
| Name                | Description                            |
|---------------------|----------------------------------------|
| security_group_id   | The ID of the created security group   |
| security_group_name | The name of the created security group |

## Notes

* The module dynamically determines the ethertype (IPv4/IPv6) for rules based on IP prefix format.
* Format remote_group_id, you can use `@self` to reference the current security group.

## License

This is an open source project under the [MIT](https://github.com/atlet99/openstack-tf-security-group-module/blob/master/LICENSE) license.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_openstack"></a> [openstack](#requirement\_openstack) | ~> 3.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_openstack"></a> [openstack](#provider\_openstack) | 3.2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Resources

| Name | Type |
|------|------|
| [openstack_networking_secgroup_rule_v2.rules](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2) | resource |
| [openstack_networking_secgroup_v2.this](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_v2) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether to create security group and all rules | `bool` | `true` | no |
| <a name="input_delete_default_rules"></a> [delete\_default\_rules](#input\_delete\_default\_rules) | Whether to delete default security group rules | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of security group | `string` | `"Managed by Terraform"` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | List of egress rules. Each rule can define:<br/>- Same structure as `ingress_rules`.<br/><br/>Example:<br/>[<br/>  {<br/>    protocol        = "tcp"<br/>    port            = 22<br/>    remote\_ip\_prefix = "0.0.0.0/0"<br/>    description     = "Allow SSH"<br/>  },<br/>  {<br/>    protocol        = "icmp"<br/>    remote\_ip\_prefix = "::/0"<br/>    description     = "Allow ICMP over IPv6"<br/>  }<br/>] | `list(map(string))` | `[]` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of ingress rules. Each rule can define:<br/>- `protocol` (optional): Protocol to allow (e.g., "tcp", "udp", "icmp", "vrrp", etc.).<br/>- `port` or `port_range_min`/`port_range_max` (optional): Single port or range.<br/>- `remote_ip_prefix` (optional): CIDR for allowed source IPs (determines ethertype).<br/>- `remote_group_id` (optional): Security group ID for allowed source. Use "@self" for current group.<br/>- `remote_address_group_id` (optional): OpenStack ID of an address group for allowed source.<br/>- `tenant_id` (optional): The owner of the rule.<br/>- `description` (optional): Description of the rule.<br/><br/>Example:<br/>[<br/>  {<br/>    protocol        = "tcp"<br/>    port            = 22<br/>    remote\_ip\_prefix = "0.0.0.0/0"<br/>    description     = "Allow SSH"<br/>  },<br/>  {<br/>    protocol        = "icmp"<br/>    remote\_ip\_prefix = "::/0"<br/>    description     = "Allow ICMP over IPv6"<br/>  }<br/>] | `list(map(string))` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of security group | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix of security group | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the security group is located | `string` | `null` | no |
| <a name="input_stateful"></a> [stateful](#input\_stateful) | Indicates if the security group is stateful or stateless | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A set of string tags to assign to security group | `set(string)` | `[]` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The owner of the security group. Required if admin wants to create a security group for another tenant. | `string` | `null` | no |
| <a name="input_use_name_prefix"></a> [use\_name\_prefix](#input\_use\_name\_prefix) | Whether to use name\_prefix before name or not | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_all_tags"></a> [security\_group\_all\_tags](#output\_security\_group\_all\_tags) | The collection of tags assigned on the security group, which have been explicitly and implicitly added |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | The name of the security group |
| <a name="output_security_group_tenant_id"></a> [security\_group\_tenant\_id](#output\_security\_group\_tenant\_id) | The tenant ID of the security group |
<!-- END_TF_DOCS -->