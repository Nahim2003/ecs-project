data "aws_route53_zone" "zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "tm_alias" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "tm.${var.domain_name}"
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_hosted_zone_id   # ← ALB’s zone id, not your hosted zone id
    evaluate_target_health = true
  }
}
