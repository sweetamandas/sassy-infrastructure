locals {
  dashboard_fqdn     = "dashboard${local.subdomain_suffix}.sweetamandas.com"
  dashboard_origin   = "https://${local.dashboard_fqdn}"
  dashboard_port     = 3001
  dashboard_hmr_port = 5001
}

# TLS Certificate using ACM
module "dashboard_cert" {
  source = "./modules/cert-request"

  aws_region     = "${var.aws_region}"
  environment    = "${var.environment}"
  hosted_zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  fqdn           = "${local.dashboard_fqdn}"
}

# Create DNS record
resource "aws_route53_record" "dashboard" {
  zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  name    = "${local.dashboard_fqdn}"
  type    = "A"

  alias = {
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = false
  }
}

# Attach TLS certificate to load balancer
resource "aws_lb_listener_certificate" "dashboard" {
  listener_arn    = "${aws_lb_listener.https.arn}"
  certificate_arn = "${module.dashboard_cert.certificate_arn}"
}

# Create target group for ALB
resource "aws_lb_target_group" "dashboard" {
  name     = "sassy-${var.environment}-dashboard"
  port     = "${local.dashboard_port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"

  health_check {
    path    = "/status"
    matcher = "200-299"
  }
}

# Add HTTP listener rule
resource "aws_lb_listener_rule" "http_dashboard" {
  listener_arn = "${aws_lb_listener.http.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.dashboard.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.dashboard_fqdn}"]
  }
}

# Add HTTPS listener rule
resource "aws_lb_listener_rule" "https_dashboard" {
  listener_arn = "${aws_lb_listener.https.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.dashboard.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.dashboard_fqdn}"]
  }
}

# Store SSM parameters for ports, etc
resource "aws_ssm_parameter" "dashboard_origin" {
  name  = "/sassy/${var.environment}/apps/dashboard/origin"
  type  = "String"
  value = "${local.dashboard_origin}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "dashboard_port" {
  name  = "/sassy/${var.environment}/apps/dashboard/port"
  type  = "String"
  value = "${local.dashboard_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "dashboard_hmr_port" {
  name  = "/sassy/${var.environment}/apps/dashboard/hmr-port"
  type  = "String"
  value = "${local.dashboard_hmr_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}
