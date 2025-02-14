variable "configs" {
  type = any
}

variable "rds_instance_endpoint" {
  type = string
}

variable "rds_reporting_instance_endpoint" {
  type    = string
  default = ""
}
