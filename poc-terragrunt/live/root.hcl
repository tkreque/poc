locals {
  # Default Setup
  env_vars = yamldecode(file(find_in_parent_folders("env.yml")))

  aws_region      = "eu-central-1"
  aws_region_code = "euc1"

  account_id      = local.env_vars.account.id
  account_name    = local.env_vars.account.name
  account_code    = local.env_vars.account.code
  account_profile = local.env_vars.account.profile

  environment = local.env_vars.account.environment

  project_name    = "poc"
  resource_prefix = "${local.account_code}-${local.aws_region_code}-${local.project_name}"

  aws_tags = {
    Environment = local.environment,
    Project     = local.project_name
  }

  # AWS Config

  ## VPC
  vpc_name = "${local.resource_prefix}-vpc"

  ## KMS
  kms_name = "${local.resource_prefix}-kms-encryption-key"

  ## EC2
  ec2_name_prefix           = "${local.resource_prefix}-ec2"
  ec2_role_name             = "${local.resource_prefix}-ec2-role"
  ec2_instance_profile_name = "${local.resource_prefix}-ec2-instance-profile"

  ## RDS
  rds_name_prefix          = "${local.resource_prefix}-db"
  rds_subnet_group_name    = "${local.resource_prefix}-db-subnet-group"
  rds_parameter_group_name = "${local.resource_prefix}-db-parameter-group"

}

inputs = {
  aws_tags = local.aws_tags
}

remote_state {
  backend = "s3"
  config = {
    profile = local.account_profile
    bucket  = "tf-states.tkreque.com"
    key     = "${local.project_name}/${path_relative_to_include()}/terraform.tfstate"
    region  = local.aws_region
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

variable "aws_tags" {
  type = map
}

provider "aws" {
  region = "${local.aws_region}"
  allowed_account_ids = ["${local.account_id}"]
  profile = "${local.account_profile}"

  default_tags {
    tags = var.aws_tags
  }
}
EOF
}

generate "versions" {
  path = "versions_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.56.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}
EOF
}