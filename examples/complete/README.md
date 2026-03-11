# Complete Security Group Example

This example demonstrates how to completely configure an OpenStack security group, including complex ingress and egress rules, tags, explicitly stated region, tenant_id attributes, reference to self, and more using this module.

## Usage

To run this example, execute:

```bash
terraform init
terraform plan
terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_openstack"></a> [openstack](#requirement\_openstack) | ~> 3.2.0 |

## Providers

No providers.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sg_all_tags"></a> [sg\_all\_tags](#output\_sg\_all\_tags) | n/a |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | n/a |
<!-- END_TF_DOCS -->