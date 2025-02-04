terraform {
  source = "../../../..//layers/db/mysql-user"
}

include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "rds" {
  config_path = "../../aws/rds"

  mock_outputs = {
    rds_instance_endpoints = ["mock-db-app:9999", "mock-db-reporting:9999"]
  }
}

dependency "schemas" {
  config_path  = "../app-db-schemas"
  skip_outputs = true
}

inputs = {
  rds_instance_endpoint = one([for endpoint in dependency.rds.outputs.rds_instance_endpoints : endpoint if can(regex("db-app", endpoint))])
  database_root         = include.locals.env_vars.rds.db-app.authentication.root
  database_users        = include.locals.env_vars.rds.db-app.authentication.users
}