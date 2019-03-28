output "primary_endpoint" {
  description = "Primary endpoint address"
  value       = "${aws_elasticache_replication_group.replication_group.primary_endpoint_address}"
}
