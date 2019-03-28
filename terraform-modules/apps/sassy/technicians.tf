locals {
  technicians_fqdn     = "technicians${local.subdomain_suffix}.sweetamandas.com"
  technicians_origin   = "https://${local.technicians_fqdn}"
  technicians_port     = 3006
  technicians_hmr_port = 5006
}

# TLS Certificate using ACM
module "technicians_cert" {
  source = "./modules/cert-request"

  aws_region     = "${var.aws_region}"
  environment    = "${var.environment}"
  hosted_zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  fqdn           = "${local.technicians_fqdn}"
}

# Create DNS record
resource "aws_route53_record" "technicians" {
  zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  name    = "${local.technicians_fqdn}"
  type    = "A"

  alias = {
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = false
  }
}

# Attach TLS certificate to load balancer
resource "aws_lb_listener_certificate" "technicians" {
  listener_arn    = "${aws_lb_listener.https.arn}"
  certificate_arn = "${module.technicians_cert.certificate_arn}"
}

# Create target group for ALB
resource "aws_lb_target_group" "technicians" {
  name     = "sassy-${var.environment}-technicians"
  port     = "${local.technicians_port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"

  health_check {
    path    = "/status"
    matcher = "200-299"
  }
}

# Add HTTP listener rule
resource "aws_lb_listener_rule" "http_technicians" {
  listener_arn = "${aws_lb_listener.http.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.technicians.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.technicians_fqdn}"]
  }
}

# Add HTTPS listener rule
resource "aws_lb_listener_rule" "https_technicians" {
  listener_arn = "${aws_lb_listener.https.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.technicians.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.technicians_fqdn}"]
  }
}

# Store SSM parameters for ports, etc
resource "aws_ssm_parameter" "technicians_origin" {
  name  = "/sassy/${var.environment}/apps/technicians/origin"
  type  = "String"
  value = "${local.technicians_origin}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "technicians_port" {
  name  = "/sassy/${var.environment}/apps/technicians/port"
  type  = "String"
  value = "${local.technicians_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "technicians_hmr_port" {
  name  = "/sassy/${var.environment}/apps/technicians/hmr-port"
  type  = "String"
  value = "${local.technicians_hmr_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}
