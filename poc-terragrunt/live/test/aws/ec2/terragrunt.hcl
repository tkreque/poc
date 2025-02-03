terraform {
  source = "../../../..//layers/aws/ec2"
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

dependency "rds" {
  config_path = "../rds"

  mock_outputs = {
    rds_security_group_ids = ["mock-rds-sg-id"]
  }
}

inputs = {
  configs                = include.locals
  vpc_id                 = dependency.vpc.outputs.vpc_id
  vpc_subnets            = dependency.vpc.outputs.vpc_public_subnet_ids
  rds_security_group_ids = dependency.rds.outputs.rds_security_group_ids
}