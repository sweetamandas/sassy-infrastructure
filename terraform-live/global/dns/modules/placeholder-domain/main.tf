resource "aws_route53_zone" "zone" {
  name = "${var.name}"
}

# Add gmail verification records
module "gmail" {
  source = "../gmail-verification"

  zone_id     = "${aws_route53_zone.zone.zone_id}"
  name        = "${var.name}"
  dkim_record = "${var.dkim_record}"
}
