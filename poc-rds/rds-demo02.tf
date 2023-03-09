resource "aws_db_instance" "rds-demo02" {
  engine               = "sqlserver-se"
  engine_version       = "15.00.4236.7.v1"
  instance_class       = "db.t3.xlarge"
  license_model        = "license-included"

  identifier           = "${var.project_name}-rds-demo02"
  username             = "myrootuser"
  password             = "myrootpassword"

  multi_az                    = false
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false

  storage_type          = "gp3"
  allocated_storage     = 40
  max_allocated_storage = 50

  db_subnet_group_name                  = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids                = [aws_security_group.mysql_rds.id]
  performance_insights_enabled          = false
  # performance_insights_retention_period = 7

  skip_final_snapshot = true
  publicly_accessible = true
  apply_immediately   = true

  backup_retention_period = 7
	backup_window           = "01:00-03:00"
	
  tags = {
		Name = "${var.project_name}-rds-demo2"
	}
}