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

data "terraform_remote_state" "sns_alerts" {
  backend = "s3"

  config {
    bucket = "sweetamandas-terraform-state"
    key    = "sassy/global/sns-alerts/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"

  config {
    bucket = "sweetamandas-terraform-state"
    key    = "sassy/${var.environment}/security/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ssm_parameter" "mysql_password" {
  name = "/sassy/${var.environment}/mysql/password"
}

# Get latest production snapshot
data "aws_db_snapshot" "latest_prod_snapshot" {
  db_instance_identifier = "sassy-production-mysql"
  most_recent            = true
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "1.22.0"

  identifier = "sassy-${var.environment}-mysql"

  # Engine and storage configuration
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "${var.instance_type}"
  allocated_storage = 100

  username = "sassy"
  password = "${data.aws_ssm_parameter.mysql_password.value}"
  port     = "3306"

  storage_type = "gp2"

  # Network and connectivity
  vpc_security_group_ids = ["${data.terraform_remote_state.vpc.mysql_security_group_id}"]
  subnet_ids             = "${data.terraform_remote_state.vpc.public_subnets}"
  multi_az               = "${var.multi_az}"

  # Needs to be publicly available so UPS WorldShip PC can access. Probably
  # should come up with a better solution to this (i.e. VPN, etc)
  publicly_accessible = true

  # Backups and maintenance
  final_snapshot_identifier = "sassy-${var.environment}-mysql"
  backup_retention_period   = "${var.backup_retention_period}"
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  maintenance_window        = "tue:08:00-tue:09:30"
  backup_window             = "07:00-08:00"

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Initial snapshot
  snapshot_identifier = "${var.use_latest_production_snapshot ? "${data.aws_db_snapshot.latest_prod_snapshot.id}" : "${var.snapshot_identifier}"}"

  # Database Deletion Protection
  deletion_protection = "${var.deletion_protection}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "mysql_host" {
  name        = "/sassy/${var.environment}/mysql/host"
  description = "SASSY ${var.environment} MySQL host address"
  type        = "String"
  value       = "${module.db.this_db_instance_address}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "mysql_port" {
  name        = "/sassy/${var.environment}/mysql/port"
  description = "SASSY ${var.environment} MySQL database port number"
  type        = "String"
  value       = "${module.db.this_db_instance_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "mysql_username" {
  name        = "/sassy/${var.environment}/mysql/user"
  description = "SASSY ${var.environment} MySQL master username"
  type        = "String"
  value       = "${module.db.this_db_instance_username}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

# Setup event subscription
resource "aws_db_event_subscription" "default" {
  count = "${var.enable_alerts ? 1 : 0}"

  name      = "sassy-${var.environment}-mysql"
  sns_topic = "${data.terraform_remote_state.sns_alerts.system_alert_topic_arn}"

  source_type = "db-instance"
  source_ids  = ["${module.db.this_db_instance_id}"]

  event_categories = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "read replica",
    "recovery",
    "restoration",
  ]
}
