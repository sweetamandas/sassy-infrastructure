locals {
  partners_fqdn     = "partners${local.subdomain_suffix}.sweetamandas.com"
  partners_origin   = "https://${local.partners_fqdn}"
  partners_port     = 3005
  partners_hmr_port = 5005
}

# TLS Certificate using ACM
module "partners_cert" {
  source = "./modules/cert-request"

  aws_region     = "${var.aws_region}"
  environment    = "${var.environment}"
  hosted_zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  fqdn           = "${local.partners_fqdn}"
}

# Create DNS record
resource "aws_route53_record" "partners" {
  zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  name    = "${local.partners_fqdn}"
  type    = "A"

  alias = {
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = false
  }
}

# Attach TLS certificate to load balancer
resource "aws_lb_listener_certificate" "partners" {
  listener_arn    = "${aws_lb_listener.https.arn}"
  certificate_arn = "${module.partners_cert.certificate_arn}"
}

# Create target group for ALB
resource "aws_lb_target_group" "partners" {
  name     = "sassy-${var.environment}-partners"
  port     = "${local.partners_port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"

  health_check {
    path    = "/status"
    matcher = "200-299"
  }
}

# Add HTTP listener rule
resource "aws_lb_listener_rule" "http_partners" {
  listener_arn = "${aws_lb_listener.http.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.partners.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.partners_fqdn}"]
  }
}

# Add HTTPS listener rule
resource "aws_lb_listener_rule" "https_partners" {
  listener_arn = "${aws_lb_listener.https.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.partners.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.partners_fqdn}"]
  }
}

# Store SSM parameters for ports, etc
resource "aws_ssm_parameter" "partners_origin" {
  name  = "/sassy/${var.environment}/apps/partners/origin"
  type  = "String"
  value = "${local.partners_origin}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "partners_port" {
  name  = "/sassy/${var.environment}/apps/partners/port"
  type  = "String"
  value = "${local.partners_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "partners_hmr_port" {
  name  = "/sassy/${var.environment}/apps/partners/hmr-port"
  type  = "String"
  value = "${local.partners_hmr_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}
