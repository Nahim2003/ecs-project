variable "private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "cluster_name" {
  type    = string
  default = "tm-ecs"
}

variable "container_image" {
  type    = string
  default = ""
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "alb_target_group_arn" {
  type    = string
  default = ""
}

variable "alb_sg_id" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
}

