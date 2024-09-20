provider "aws" {
  region  = "eu-central-1"
  profile = "<my_prime_account_profile>"
  default_tags {
    tags = {
      environment = "poc",
      created_on  = "2024-09"
    }
  }
}

provider "aws" {
  alias   = "dev"
  region  = "eu-central-1"
  profile = "<my_dev_account_profile>"
  default_tags {
    tags = {
      environment = "poc",
      created_on  = "2024-09"
    }
  }
}

provider "aws" {
  alias   = "test"
  region  = "eu-central-1"
  profile = "<my_test_account_profile>"
  default_tags {
    tags = {
      environment = "poc",
      created_on  = "2024-09"
    }
  }
}

provider "aws" {
  alias   = "prod"
  region  = "eu-central-1"
  profile = "<my_prod_account_profile>"
  default_tags {
    tags = {
      environment = "poc",
      created_on  = "2024-09"
    }
  }
}

terraform {
  required_version = ">= 1.0.0"
  backend "local" {
    path = "./terraform.state"
  }
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