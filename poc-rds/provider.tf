provider "aws" {
  region  = "eu-central-1"
  profile = "tf-projects"
  default_tags {
    tags = {
      environment = "poc",
      created_on = "2022-03-23"
    }
  }
}

terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    profile = "tf-projects"
    bucket  = "tf-states.tkreque.eu"    
    key     = "eu/tkreque/rds/terraform.state"    
    region  = "eu-central-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}