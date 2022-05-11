locals {
  az_names        = [for az in var.azs : "${data.aws_region.current.name}${az}"]
  vpc_cidr        = "10.2.16.0/20"
  private_subnets = ["10.2.16.0/24","10.2.17.0/24","10.2.18.0/24"]
  public_subnets  = ["10.2.19.0/24","10.2.20.0/24","10.2.21.0/24"]
}

data "aws_region" "current" {}

######
# VPC
######
resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.project_name}-default-unused" }
}

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id
  tags = { Name = "${var.project_name}-default-unused" }
}

#################
# Private Subnet
#################
resource "aws_subnet" "private" {
  count = length(local.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.az_names[count.index]
  tags = {
    "Name" = "${var.project_name}-private-az${var.azs[count.index]}",
  }
}

resource "aws_route_table" "private" {
  count = length(local.private_subnets)

  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.project_name}-private-az${var.azs[count.index]}" }
}

resource "aws_route_table_association" "private" {
  count = length(local.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#################
# Public Subnet
#################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.project_name}-igw" }
}

resource "aws_subnet" "public" {
  count = length(local.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true
  tags = {
    "Name"  = "${var.project_name}-public-az${var.azs[count.index]}",
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.project_name}-public-az" }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count = length(local.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}