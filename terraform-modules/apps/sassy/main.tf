provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.59"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

locals {
  subdomain_suffix = "${var.environment == "production" ? "" : ".${var.environment}"}"
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "dns" {
  backend = "s3"

  config {
    bucket = "sweetamandas-terraform-state"
    key    = "sassy/global/dns/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "sweetamandas-terraform-state"
    key    = "sassy/${var.environment}/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}
