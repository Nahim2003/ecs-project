variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "subdomain" {
  type = string
}

variable "container_image" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "container_port" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "tags" {
  type = map(string)
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}
