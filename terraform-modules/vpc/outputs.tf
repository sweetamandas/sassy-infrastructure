output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${module.vpc.vpc_cidr_block}"
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = "${module.vpc.public_subnets}"
}

output "mysql_security_group_id" {
  description = "ID of security group for MySQL server"
  value       = "${aws_security_group.mysql.id}"
}

output "redis_security_group_id" {
  description = "ID of security group for Redis cluster"
  value       = "${aws_security_group.redis.id}"
}

output "alb_security_group_id" {
  description = "ID of security group for ALB"
  value       = "${aws_security_group.alb.id}"
}

output "server_security_group_id" {
  description = "ID of security group for server"
  value       = "${aws_security_group.server.id}"
}
