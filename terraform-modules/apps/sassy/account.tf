locals {
  account_fqdn     = "account${local.subdomain_suffix}.sweetamandas.com"
  account_origin   = "https://${local.account_fqdn}"
  account_port     = 3003
  account_hmr_port = 5003
}

# TLS Certificate using ACM
module "account_cert" {
  source = "./modules/cert-request"

  aws_region     = "${var.aws_region}"
  environment    = "${var.environment}"
  hosted_zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  fqdn           = "${local.account_fqdn}"
}

# Create DNS record
resource "aws_route53_record" "account" {
  zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  name    = "${local.account_fqdn}"
  type    = "A"

  alias = {
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = false
  }
}

# Attach TLS certificate to load balancer
resource "aws_lb_listener_certificate" "account" {
  listener_arn    = "${aws_lb_listener.https.arn}"
  certificate_arn = "${module.account_cert.certificate_arn}"
}

# Create target group for ALB
resource "aws_lb_target_group" "account" {
  name     = "sassy-${var.environment}-account"
  port     = "${local.account_port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"

  health_check {
    path    = "/status"
    matcher = "200-299"
  }
}

# Add HTTP listener rule
resource "aws_lb_listener_rule" "http_account" {
  listener_arn = "${aws_lb_listener.http.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.account.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.account_fqdn}"]
  }
}

# Add HTTPS listener rule
resource "aws_lb_listener_rule" "https_account" {
  listener_arn = "${aws_lb_listener.https.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.account.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.account_fqdn}"]
  }
}

# Store SSM parameters for ports, etc
resource "aws_ssm_parameter" "account_origin" {
  name  = "/sassy/${var.environment}/apps/account/origin"
  type  = "String"
  value = "${local.account_origin}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "account_port" {
  name  = "/sassy/${var.environment}/apps/account/port"
  type  = "String"
  value = "${local.account_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "account_hmr_port" {
  name  = "/sassy/${var.environment}/apps/account/hmr-port"
  type  = "String"
  value = "${local.account_hmr_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}
