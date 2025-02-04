resource "aws_security_group" "rds" {
  for_each    = { for index, rds in var.configs.env_vars.rds : rds.name => rds }
  name        = "${var.configs.resource_prefix}-${each.key}-sg"
  description = "RDS security group for ${each.key} DB"
  vpc_id      = var.vpc_id

  tags = { "Name" : "${var.configs.resource_prefix}-${each.key}-sg" }
}

resource "aws_security_group_rule" "RDS_egress_internet" {
  for_each          = { for index, rds in var.configs.env_vars.rds : rds.name => rds }
  security_group_id = aws_security_group.rds[each.key].id
  description       = "Allow RDS egress access to the Internet."
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "RDS_ingress" {
  for_each          = { for index, rds in var.configs.env_vars.rds : rds.name => rds }
  security_group_id = aws_security_group.rds[each.key].id
  description       = "Allow to communicate with the RDS."
  type              = "ingress"
  from_port         = each.value.access.port
  to_port           = each.value.access.port
  protocol          = "tcp"
  cidr_blocks       = each.value.access.allow
}