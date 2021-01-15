# Route53 DNS Record
data "aws_route53_zone" "selected" {
  name = "hashicorp-success.com."
}

resource "aws_route53_record" "flamarion" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "${var.dns_record_name}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
