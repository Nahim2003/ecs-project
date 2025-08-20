variable "vpc_id" {
  type    = string
  default = ""
}

variable "pubic_subnet_ids" {
  type    = list(string)
  default = []
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "health_check_path" {
  type    = string
  default = "/healthz"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "container_port" {
  type = number
  default = 3000
}