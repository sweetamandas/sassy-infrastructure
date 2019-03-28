provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.59"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "sweetamandas-terraform-state"
    key    = "sassy/${var.environment}/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = "sassy-${var.environment}-redis"
  subnet_ids = ["${data.terraform_remote_state.vpc.public_subnets}"]
}

resource "aws_elasticache_parameter_group" "default" {
  name        = "sassy-${var.environment}-redis-parameters"
  description = "Redis parameter group for SASSY ${var.environment}"
  family      = "redis5.0"
}

resource "aws_elasticache_replication_group" "replication_group" {
  replication_group_id          = "sassy-${var.environment}-redis"
  replication_group_description = "Redis replication group for SASSY ${var.environment}"

  engine               = "redis"
  engine_version       = "5.0.0"
  parameter_group_name = "${aws_elasticache_parameter_group.default.id}"
  node_type            = "${var.node_type}"

  automatic_failover_enabled = "${var.automatic_failover_enabled}"
  number_cache_clusters      = "${var.number_cache_clusters}"

  subnet_group_name  = "${aws_elasticache_subnet_group.subnet_group.name}"
  security_group_ids = ["${data.terraform_remote_state.vpc.redis_security_group_id}"]
  port               = 6379

  maintenance_window       = "tue:08:00-tue:09:30"
  snapshot_retention_limit = "0"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "redis_host" {
  name        = "/sassy/${var.environment}/redis/host"
  description = "Redis primary endpoint host for SASSY ${var.environment}"
  type        = "String"

  # Endpoint output from redis module does not include port number
  value = "${aws_elasticache_replication_group.replication_group.primary_endpoint_address}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "redis_port" {
  name        = "/sassy/${var.environment}/redis/port"
  description = "Redis primary endpoint port number for SASSY ${var.environment}"
  type        = "String"
  value       = "6379"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}
