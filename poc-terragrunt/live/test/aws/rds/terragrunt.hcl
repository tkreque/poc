terraform {
  source = "../../../..//layers/aws/rds"
}

include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                = "mock-vpc-id"
    vpc_public_subnet_ids = ["mock-subnet-ida", "mock-subnet-idb"]
  }
}

inputs = {
  configs     = include.locals
  vpc_id      = dependency.vpc.outputs.vpc_id
  vpc_subnets = dependency.vpc.outputs.vpc_public_subnet_ids
}