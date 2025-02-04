provider "mysql" {
  endpoint = var.rds_instance_endpoint
  username = var.database_root.user
  password = var.database_root.password
}

resource "mysql_database" "schema" {
  for_each              = { for schema in var.database_schemas : schema.schema => schema }
  name                  = each.key
  default_collation     = each.value.collation
  default_character_set = each.value.charset
}