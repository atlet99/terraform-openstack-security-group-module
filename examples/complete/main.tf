module "complete_sg" {
  source = "../../"

  name        = "complete-sg"
  description = "Security group with multiple rules"
  tags        = ["terraform", "complete"]

  ingress_rules = [
    {
      protocol         = "tcp"
      port             = 22
      remote_ip_prefix = "0.0.0.0/0"
      description      = "Allow SSH"
    },
    {
      protocol         = "tcp"
      port             = 80
      remote_ip_prefix = "0.0.0.0/0"
      description      = "Allow HTTP"
    },
    {
      protocol        = "tcp"
      port            = 3306
      remote_group_id = "@self"
      description     = "Allow MySQL from self"
    }
  ]

  egress_rules = [
    {
      protocol         = "tcp"
      port             = 443
      remote_ip_prefix = "0.0.0.0/0"
      description      = "Allow HTTPS"
    }
  ]
}

output "sg_id" {
  value = module.complete_sg.security_group_id
}

output "sg_all_tags" {
  value = module.complete_sg.security_group_all_tags
}
