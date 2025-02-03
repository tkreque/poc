provider "random" {
  # Configuration options
}

resource "random_integer" "ec2" {
  min = 0
  max = length(var.configs.env_vars.vpc.azs)
}