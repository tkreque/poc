variable "rds_instance_endpoint" {
  type = string
}

variable "database_users" {
  type = list(any)
}

variable "database_root" {
  type = object({
    user     = string
    password = string
  })
}