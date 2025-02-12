include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "global" {
  path   = "${get_terragrunt_dir()}/../../../_global/db/mysql/users.hcl"
  expose = true
}

dependency "schemas" {
  config_path  = "../reporting-db-schemas"
  skip_outputs = true
}

inputs = {
  rds_instance_endpoint = one([for endpoint in dependency.rds.outputs.rds_instance_endpoints : endpoint if can(regex("db-reporting", endpoint))])
  database_root         = include.root.locals.env_vars.rds.db-reporting.authentication.root
  database_users        = include.root.locals.env_vars.rds.db-reporting.authentication.users
}