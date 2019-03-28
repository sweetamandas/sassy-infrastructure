output "primary_hosted_zone_id" {
  description = "ID of main hosted zone (i.e. sweetamandas.com)"
  value       = "${aws_route53_zone.sweetamandas_com.zone_id}"
}
