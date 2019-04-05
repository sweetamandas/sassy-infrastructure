provider "aws" {
  region  = "us-east-1"
  version = "~> 1.59"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource "aws_sns_topic" "alerts" {
  name = "system-alerts"
}

# Subscriptions to this topic are currently via email which is not supported
# via terraform. These subscriptions are set manually via the web console.

