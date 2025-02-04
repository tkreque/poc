resource "aws_db_subnet_group" "db_subnet" {
  name       = var.configs.rds_subnet_group_name
  subnet_ids = var.vpc_subnets
}