resource "aws_db_instance" "rds" {
  for_each       = { for index, rds in var.configs.env_vars.rds : rds.name => rds }
  engine         = each.value.engine
  engine_version = each.value.version
  instance_class = each.value.class

  identifier           = "${var.configs.rds_name_prefix}-${each.key}"
  db_name              = each.value.default_schema
  username             = each.value.authentication.root.user
  password             = each.value.authentication.root.password

  multi_az                    = each.value.multi_az
  auto_minor_version_upgrade  = each.value.maintenance.auto_minor_upgrade
  allow_major_version_upgrade = each.value.maintenance.auto_major_upgrade

  storage_type          = each.value.storage.type
  allocated_storage     = each.value.storage.allocated
  max_allocated_storage = each.value.storage.max_allocated

  db_subnet_group_name                  = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids                = [aws_security_group.rds[each.key].id]

  skip_final_snapshot = true
  publicly_accessible = true
  apply_immediately   = true

  backup_retention_period = each.value.backup.retention
	backup_window           = each.value.backup.window
	
  tags = {
		Name = "${var.configs.rds_name_prefix}-${each.key}"
    App = each.key
	}
}