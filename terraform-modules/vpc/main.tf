provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.59"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.55.0"

  name = "sassy-${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs            = "${slice(data.aws_availability_zones.available.names, 0, var.max_az_count)}"
  public_subnets = "${slice(list("10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"), 0, length(slice(data.aws_availability_zones.available.names, 0, var.max_az_count)))}"

  # This is to allow RDS public access
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "alb" {
  name        = "sassy-${var.environment}-alb"
  description = "Rules for SASSY ${var.environment} ALB"
  vpc_id      = "${module.vpc.vpc_id}"

  # Allow http access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow https access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow machine api access
  ingress {
    from_port   = 24267
    to_port     = 24267
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP (ping) access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "server" {
  name        = "sassy-${var.environment}-server"
  description = "Rules for SASSY ${var.environment} server"
  vpc_id      = "${module.vpc.vpc_id}"

  # Allow ssh access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow load balancer access
  ingress {
    from_port       = 3001
    to_port         = 3006
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  ingress {
    from_port       = 24267
    to_port         = 24267
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "mysql" {
  name        = "sassy-${var.environment}-mysql"
  description = "Rules for SASSY ${var.environment} MySQL server"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.server.id}"]
  }

  # Allow ingress from Tallmadge office. This is necessary so WorldShip on
  # shipping PC can fetch orders, etc form database. In the future it might
  # be better to setup a VPN, or something for this.
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["173.89.66.159/32"]
    description = "Tallmadge office"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "redis" {
  name        = "sassy-${var.environment}-redis"
  description = "Rules for SASSY ${var.environment} Redis cluster"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = ["${aws_security_group.server.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}
