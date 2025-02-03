variable "configs" {
  type = any
}

variable "vpc_id" {
  type = string
}

variable "vpc_subnets" {
  type = list(string)
}