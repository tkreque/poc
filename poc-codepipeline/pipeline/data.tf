data "aws_region" "current" {}

data "aws_caller_identity" "prime" {}

data "aws_caller_identity" "dev" {
  provider = aws.dev
}

data "aws_caller_identity" "prod" {
  provider = aws.prod
}