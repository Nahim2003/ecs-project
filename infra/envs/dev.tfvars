project        = "tm-tool"
env            = "dev"
region         = "eu-west-1"

domain_name    = "nahimtm.xyz"
subdomain      = "tm"

container_image = "764283926008.dkr.ecr.eu-west-1.amazonaws.com/tm-tool"
image_tag       = "latest"
container_port  = 3000
health_check_path = "/healthz"

desired_count = 2
cpu           = 256
memory        = 512

tags = {
  Project = "tm-tool"
  Env     = "dev"
  Owner   = "Nahim"
}

vpc_cidr             = "10.0.0.0/16"
azs                  = ["eu-west-1a", "eu-west-1b"]
public_subnet_cidrs  = ["10.0.0.0/20", "10.0.16.0/20"]
private_subnet_cidrs = ["10.0.128.0/20", "10.0.144.0/20"]

