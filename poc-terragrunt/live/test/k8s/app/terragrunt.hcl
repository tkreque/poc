include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "global" {
  path   = "${get_terragrunt_dir()}/../../../_global/k8s/app.hcl"
  expose = true
}

inputs = {
  configs                         = include.root.locals
  rds_instance_endpoint           = one([for endpoint in dependency.rds.outputs.rds_instance_endpoints : endpoint if can(regex("db-app", endpoint))])
  rds_reporting_instance_endpoint = one([for endpoint in dependency.rds.outputs.rds_instance_endpoints : endpoint if can(regex("db-reporting", endpoint))])
}