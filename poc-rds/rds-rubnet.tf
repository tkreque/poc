resource "aws_db_subnet_group" "db_subnet" {
	name 					= "${var.project_name}-rds-subnet"
	subnet_ids		= aws_subnet.public.*.id
}