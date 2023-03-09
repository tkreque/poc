resource "aws_rds_cluster" "mysql_rds_cluster" {
	cluster_identifier	    = "${var.project_name}-aurora"
	engine					        = "aurora-mysql"
	engine_version			    = "5.7.mysql_aurora.2.07.2"
	availability_zones	    = local.az_names
	database_name			      = "mydbname"
	master_username			    = "myrootuser"
	master_password			    = "myrootpassword"
	backup_retention_period = 7
	preferred_backup_window = "01:00-03:00"
	vpc_security_group_ids 	= [aws_security_group.mysql_rds.id]
	db_subnet_group_name	  = aws_db_subnet_group.db_subnet.name
	storage_encrypted		    = true
	skip_final_snapshot		  = true
	deletion_protection		  = false

	tags = {
		Name = "${var.project_name}-aurora"
	}
}

resource "aws_rds_cluster_instance" "mysql_rds_cluster_instance" {
	count					      = 1
	identifier 				  = "${var.project_name}-aurora-${count.index}"
	cluster_identifier	= aws_rds_cluster.mysql_rds_cluster.id
	instance_class			= "db.t3.small"
	engine 					    = aws_rds_cluster.mysql_rds_cluster.engine
	engine_version			= aws_rds_cluster.mysql_rds_cluster.engine_version
	publicly_accessible = true
}