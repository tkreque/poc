variable "region" {
  type = string
  default = "eu-central-1"
}
variable "project_name" {
  type = string
  default = "tkr"
}
variable "azs" {
  type = list(string)
  default		= [
    "a",
    "b"
  ]
}
variable "hosted_zone_id" {
  type = string
  default = "Z05993183UONRK0W5INDW"
}
variable "hosted_zone_name" {
  type = string
  default = "tkreque.eu"
}