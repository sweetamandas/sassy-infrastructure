# MX Records
resource "aws_route53_record" "mx" {
  zone_id = "${var.zone_id}"
  name    = "${var.name}"
  type    = "MX"
  records = ["1 ASPMX.L.GOOGLE.COM", "5 ALT1.ASPMX.L.GOOGLE.COM", "5 ALT2.ASPMX.L.GOOGLE.COM", "10 ALT3.ASPMX.L.GOOGLE.COM", "10 ALT4.ASPMX.L.GOOGLE.COM"]
  ttl     = "3600"
}

# SPF Record
resource "aws_route53_record" "spf" {
  zone_id = "${var.zone_id}"
  name    = "${var.name}"
  type    = "TXT"
  records = ["v=spf1 include:_spf.google.com ~all"]
  ttl     = "3600"
}

resource "aws_route53_record" "dkim" {
  count = "${var.dkim_record != "" ? 1 : 0}"

  zone_id = "${var.zone_id}"
  name    = "sweetamandas._domainkey.${var.name}"
  type    = "TXT"
  records = ["${var.dkim_record}"]
  ttl     = "3600"
}
