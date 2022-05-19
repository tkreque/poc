variable "region" {
  type = string
  default = "eu-west-1"
}
variable "project_name" {
  type = string
  default = "ufo-dms"
}
variable "azs" {
  type = list(string)
  default		= [
    "a",
    "b",
    "c"
  ]
}