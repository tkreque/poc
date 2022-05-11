locals {
  rds_sg_name     = "${var.project_name}-rds-sg"
  cidrs_allowed       = ["212.24.219.214/32","83.222.50.35/32"]
}

#########
# RDS SG
#########

resource "aws_security_group" "mysql_rds" {
  name        = local.rds_sg_name
  description = "RDS cluster security group"
  vpc_id      = aws_vpc.this.id

  tags = { "Name" : local.rds_sg_name }
}

resource "aws_security_group_rule" "RDS_egress_internet" {
  security_group_id = aws_security_group.mysql_rds.id
  description       = "Allow RDS egress access to the Internet."
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "RDS_ingress_https" {
  security_group_id        = aws_security_group.mysql_rds.id
  description              = "Allow to communicate with the RDS cluster."
  type                     = "ingress"
  from_port                = 3036
  to_port                  = 3306
  protocol                 = "tcp"
  cidr_blocks              = local.cidrs_allowed
}