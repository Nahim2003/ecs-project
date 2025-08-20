variable "domain_name" {
  type    = string
  default = ""
}

variable "subdomain_name" {
  type    = string
  default = "tm"
}

variable "alb_dns_name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "alb_hosted_zone_id" {
  type    = string
  default = ""
}