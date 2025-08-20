# Find the public hosted zone for your domain (nahimtm.xyz)
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# 1) Network (VPC, subnets, routes)
module "network" {
  source               = "./modules/network"
  project              = var.project
  env                  = var.env
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}


# 2) ACM (cert for tm.domain)
module "acm" {
  source         = "./modules/acm"
  domain_name    = var.domain_name
  subdomain      = var.subdomain
  hosted_zone_id = data.aws_route53_zone.main.zone_id
  tags           = var.tags
}

# 3) ALB (uses network + acm)
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  certificate_arn   = module.acm.certificate_arn
  health_check_path = var.health_check_path
  project           = var.project
  env               = var.env
  tags              = var.tags
  container_port    = var.container_port
}

# 4) ECS (uses network + alb)
module "ecs" {
  source               = "./modules/ecs"
  project              = var.project
  env                  = var.env
  container_image      = var.container_image
  image_tag            = var.image_tag
  container_port       = var.container_port
  cpu                  = var.cpu
  memory               = var.memory
  desired_count        = var.desired_count
  private_subnet_ids   = module.network.private_subnet_ids
  alb_target_group_arn = module.alb.target_group_arn
  alb_sg_id            = module.alb.alb_sg_id
  tags                 = var.tags
}


# 5) DNS record for tm.domain -> ALB
module "dns" {
  source             = "./modules/dns"
  domain_name        = var.domain_name
  alb_dns_name       = module.alb.alb_dns_name
  alb_hosted_zone_id = module.alb.alb_hosted_zone_id
  tags               = var.tags
}

