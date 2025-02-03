terraform {
  source = "../../../..//layers/aws/vpc"
}

include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  configs = include.locals
}