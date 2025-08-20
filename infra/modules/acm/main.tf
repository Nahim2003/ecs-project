# Request cert for tm.nahimtm.xyz
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.subdomain}.${var.domain_name}"
  validation_method = "DNS"
  tags              = var.tags

  # optional but nice when re-applying
  lifecycle {
    create_before_destroy = true
  }
}

# Turn the set of validation options into a map we can iterate
locals {
  cert_dns = {
    for dvo in aws_acm_certificate.cert.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}

# Create the DNS validation record(s) in Route 53
resource "aws_route53_record" "cert_validation" {
  for_each        = local.cert_dns
  zone_id         = var.hosted_zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.value]
  allow_overwrite = true
}

# Tell ACM to validate using those records
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

