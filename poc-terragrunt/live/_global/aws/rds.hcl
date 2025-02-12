terraform {
  source = "../../../..//layers/aws/rds"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"

  mock_outputs = {
    vpc_id                = "mock-vpc-id"
    vpc_public_subnet_ids = ["mock-subnet-ida", "mock-subnet-idb"]
  }
}

dependency "kms" {
  config_path = "${get_terragrunt_dir()}/../kms"

  mock_outputs = {
    kms_key_arn = "arn:aws:kms:us-east-1:999999999999:key/mock-kms-key-id"
  }
}

inputs = {
  vpc_id      = dependency.vpc.outputs.vpc_id
  vpc_subnets = dependency.vpc.outputs.vpc_public_subnet_ids
  kms_key_arn = dependency.kms.outputs.kms_key_arn
}