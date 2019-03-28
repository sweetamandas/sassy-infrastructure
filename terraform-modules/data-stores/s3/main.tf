provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.59"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource "aws_s3_bucket" "primary" {
  bucket = "sweetamandas-sassy-${var.environment}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

# Store primary bucket name as config parameter
resource "aws_ssm_parameter" "s3_bucket" {
  name        = "/sassy/${var.environment}/aws/bucket"
  description = "SASSY ${var.environment} primary S3 bucket name"
  type        = "String"
  value       = "${aws_s3_bucket.primary.id}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}
