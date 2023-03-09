resource "aws_db_instance" "rds-demo01" {
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.medium"

  identifier           = "${var.project_name}-rds-demo01"
  db_name              = "demo01"
  username             = "myrootuser"
  password             = "myrootpassword"

  multi_az                    = false
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false

  storage_type          = "gp2"
  allocated_storage     = 10
  max_allocated_storage = 20

  db_subnet_group_name                  = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids                = [aws_security_group.mysql_rds.id]
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  skip_final_snapshot = true
  publicly_accessible = true
  apply_immediately   = true

  backup_retention_period = 7
	backup_window           = "01:00-03:00"
	
  tags = {
		Name = "${var.project_name}-rds-demo1"
	}
}