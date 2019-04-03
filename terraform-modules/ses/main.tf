provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.59"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

locals {
  fqdn = "${var.environment == "production" ? "sweetamandas.com" : "${var.environment}.sweetamandas.com"}"
}

data "terraform_remote_state" "dns" {
  backend = "s3"

  config {
    bucket = "sweetamandas-terraform-state"
    key    = "sassy/global/dns/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"

  config {
    bucket = "sweetamandas-terraform-state"
    key    = "sassy/${var.environment}/data-stores/s3/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

# Add domain verification records to DNS
resource "aws_ses_domain_identity" "domain_id" {
  domain = "${local.fqdn}"
}

resource "aws_route53_record" "verification_record" {
  zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  name    = "_amazonses.${local.fqdn}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.domain_id.verification_token}"]
}

# Add DKIM records to DNS
resource "aws_ses_domain_dkim" "dkim" {
  domain = "${local.fqdn}"
}

resource "aws_route53_record" "dkim_records" {
  count   = 3
  zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${local.fqdn}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# Add MX records for non-production environment. For production gmail handles
# incoming email and forwards to SES. For other environments just receive via
# SES directly
resource "aws_route53_record" "mx" {
  count   = "${var.environment == "production" ? 0 : 1}"
  zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  name    = "${local.fqdn}"
  type    = "MX"
  ttl     = "600"
  records = ["1 inbound-smtp.us-east-1.amazonaws.com"]
}

# Give SES permission to save emails in S3 bucket
resource "aws_s3_bucket_policy" "ses" {
  bucket = "${data.terraform_remote_state.s3.primary_bucket_id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSESPuts",
      "Effect": "Allow",
      "Principal": {
        "Service": "ses.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${data.terraform_remote_state.s3.primary_bucket_id}/received-emails/*",
      "Condition": {
        "StringEquals": {
          "aws:Referer": "${data.aws_caller_identity.current.account_id}"
        }
      }
    }
  ]
}
POLICY
}

# Create sns topic that forwards email delivery notifications to SQS queue
resource "aws_sns_topic" "email_receipt" {
  name = "sassy-${var.environment}-ses-receipt-topic"
}

resource "aws_sqs_queue" "email_receipt" {
  name = "sassy-${var.environment}-ses-receipt-queue"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

# Allow SNS to send messages to SQS
resource "aws_sqs_queue_policy" "email_receipt" {
  queue_url = "${aws_sqs_queue.email_receipt.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSNSSendMessage",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["sqs:SendMessage"],
      "Resource": "${aws_sqs_queue.email_receipt.arn}",
      "Condition" :{
        "ArnEquals" :{
          "aws:SourceArn":"${aws_sns_topic.email_receipt.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "email_receipt" {
  topic_arn = "${aws_sns_topic.email_receipt.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.email_receipt.arn}"
}

# Create receipt rule to store email in s3 and publish to sns topic. We cannot
# just notify sns directly because notifications can't handle attachments by
# themselves.
resource "aws_ses_receipt_rule" "store" {
  name          = "sassy-${var.environment}-store-and-notify"
  recipients    = ["${local.fqdn}"]
  rule_set_name = "default-rule-set"
  enabled       = true
  tls_policy    = "Require"

  s3_action {
    bucket_name       = "sweetamandas-sassy-${var.environment}"
    object_key_prefix = "received-emails"
    topic_arn         = "${aws_sns_topic.email_receipt.arn}"
    position          = 1
  }

  depends_on = ["aws_s3_bucket_policy.ses"]
}
