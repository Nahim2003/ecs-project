variable "domain_name" {
  type    = string
  default = "nahimtm.xyz"
}

variable "subdomain" {
  type    = string
  default = "tm"
}

variable "hosted_zone_id" {
  type    = string
  default = "Z02504502PZB0UQNC5VLH"
}

variable "tags" {
  type    = map(string)
  default = {}
}
