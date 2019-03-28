resource "aws_route53_zone" "sweetamandas_com" {
  name = "sweetamandas.com"
}

# Zone records
# Note NS and SOA records are created automatically by Route 53 and are not
# tracked in Terraform

# A record routes to main website hosted by Social Tuna
resource "aws_route53_record" "sweetamandas_com_A" {
  zone_id = "${aws_route53_zone.sweetamandas_com.zone_id}"
  name    = "sweetamandas.com"
  type    = "A"
  records = ["192.196.159.16"]
  ttl     = "600"
}

# Add gmail verification records
module "sweetamandas_com_gmail" {
  source = "./modules/gmail-verification"

  zone_id     = "${aws_route53_zone.sweetamandas_com.zone_id}"
  name        = "sweetamandas.com"
  dkim_record = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCrdPkfWZ+LVYaNUuhFgBG9ST7VA6yJLIa6+oKblaGDAavddjqg3iXmAtmEdugwuU/PqRYNxwXbtXEYrIVT1g4dd8UuypD4JlX0P7IcxhKVXW2zaRhfjUFsWSXMM9ZU2HJOYfaXwwsleHr5YdtxktSOiZ53A46ha7Una9AlV+C9pQIDAQAB"
}

# Add CNAME record to route www subdomain to root subdomain
resource "aws_route53_record" "www_sweetamandas_com_CNAME" {
  zone_id = "${aws_route53_zone.sweetamandas_com.zone_id}"
  name    = "www.sweetamandas.com"
  type    = "CNAME"
  records = ["sweetamandas.com"]
  ttl     = "3600"
}

# Google services re-routes
resource "aws_route53_record" "calendar_sweetamandas_com_CNAME" {
  zone_id = "${aws_route53_zone.sweetamandas_com.zone_id}"
  name    = "calendar.sweetamandas.com"
  type    = "CNAME"
  records = ["ghs.googlehosted.com"]
  ttl     = "3600"
}

resource "aws_route53_record" "mail_sweetamandas_com_CNAME" {
  zone_id = "${aws_route53_zone.sweetamandas_com.zone_id}"
  name    = "mail.sweetamandas.com"
  type    = "CNAME"
  records = ["ghs.googlehosted.com"]
  ttl     = "3600"
}

# App subdomains are created in their respective environment modules

