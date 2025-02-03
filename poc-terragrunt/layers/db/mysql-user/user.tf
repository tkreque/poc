locals {
  schemas_per_user = flatten([
    for user in var.database_users : [
      for schema in user.schemas : {
        schema     = schema.schema
        privileges = schema.privileges
        user       = user.user
        host       = user.host
      }
    ]
  ])
}

provider "mysql" {
  endpoint = var.rds_instance_endpoint
  username = var.database_root.user
  password = var.database_root.password
}

resource "mysql_user" "user" {
  for_each = { for index, user in var.database_users : user.user => user }
  user               = each.key
  plaintext_password = each.value.password
  host               = each.value.host
}

resource "mysql_grant" "user_grant" {
  for_each = { for index, schema in local.schemas_per_user : schema.schema => schema }
  depends_on = [ mysql_user.user ]
  user       = each.value.user
  database   = each.value.schema
  privileges = each.value.privileges
  host       = each.value.host
}