locals {
  az_names        = [for az in var.configs.env_vars.vpc.azs : "${var.configs.aws_region}${az}"]
  vpc_cidr        = var.configs.env_vars.vpc.cidr
  private_subnets = var.configs.env_vars.vpc.subnets.private
  public_subnets  = var.configs.env_vars.vpc.subnets.public
}

######
# VPC
######
resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = var.configs.vpc_name }
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.configs.vpc_name}-default-unused" }
}

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id
  tags                   = { Name = "${var.configs.vpc_name}-default-unused" }
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
    "Name" = "${var.configs.vpc_name}-private-az${local.az_names[count.index]}",
  }
}

resource "aws_route_table" "private" {
  count = length(local.private_subnets)

  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.configs.vpc_name}-private-az${local.az_names[count.index]}" }
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
  tags   = { Name = "${var.configs.project_name}-igw" }
}

resource "aws_subnet" "public" {
  count = length(local.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.configs.vpc_name}-public-az${local.az_names[count.index]}",
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.configs.vpc_name}-public-az" }
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
