resource "aws_security_group" "ec2" {
  for_each    = { for index, ec2 in var.configs.env_vars.ec2 : ec2.name => ec2 if lookup(ec2, "name", null) != null }
  name        = "${var.configs.resource_prefix}-${each.key}-sg"
  description = "Allows access to the Ec2"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { "Name" = "${var.configs.resource_prefix}-${each.key}-sg" }
}
