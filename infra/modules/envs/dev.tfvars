project        = "tm-tool"
env            = "dev"
region         = "eu-west-1"

domain_name    = "nahimtm.xyz"
subdomain      = "tm"

container_image = "nahim2003/tm-tool"
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

# Networking
vpc_cidr             = "10.0.0.0/16"

# Pick 2–3 availability zones that exist in your region (check AWS console or CLI)
azs                  = ["eu-west-1a", "eu-west-1b"]

# One public subnet per AZ
public_subnet_cidrs  = ["10.0.0.0/20", "10.0.16.0/20"]

# One private subnet per AZ
private_subnet_cidrs = ["10.0.128.0/20", "10.0.144.0/20"]

