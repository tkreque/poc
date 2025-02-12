include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "global" {
  path   = "${get_terragrunt_dir()}/../../../_global/aws/vpc.hcl"
  expose = true
}

inputs = {
  configs = include.root.locals
}