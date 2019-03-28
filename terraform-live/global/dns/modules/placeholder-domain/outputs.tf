output "zone_id" {
  description = "The id of the hosted zone"
  value       = "${aws_route53_zone.zone.zone_id}"
}
