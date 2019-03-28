provider "aws" {
  region  = "us-east-1"
  version = "~> 1.59"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

# Create global SES receipt ruleset that each environment can add rules to
resource "aws_ses_receipt_rule_set" "rules" {
  rule_set_name = "default-rule-set"
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = "default-rule-set"
}
