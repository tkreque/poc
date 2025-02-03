#################
# Output
#################

output "rds_instance_arns" {
  value = values(aws_db_instance.rds)[*].arn
}

output "rds_instance_endpoints" {
  value = values(aws_db_instance.rds)[*].endpoint
}

output "rds_security_group_ids" {
  value = values(aws_security_group.rds)[*].id
}
