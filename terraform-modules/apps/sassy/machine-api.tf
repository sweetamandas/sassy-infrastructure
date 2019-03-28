locals {
  machine_api_fqdn   = "sassy${local.subdomain_suffix}.sweetamandas.com"
  machine_api_origin = "https://${local.machine_api_fqdn}"
  machine_api_port   = 24267
}

# Import TLS cert for machine API from SSM
data "aws_ssm_parameter" "key_pem" {
  name = "/tls-certs/sassy.sweetamandas.com/key"
}

data "aws_ssm_parameter" "cert_pem" {
  name = "/tls-certs/sassy.sweetamandas.com/cert"
}

data "aws_ssm_parameter" "ca_pem" {
  name = "/tls-certs/sassy.sweetamandas.com/ca"
}

resource "aws_acm_certificate" "machine_api_cert" {
  private_key       = "${data.aws_ssm_parameter.key_pem.value}"
  certificate_body  = "${data.aws_ssm_parameter.cert_pem.value}"
  certificate_chain = "${data.aws_ssm_parameter.ca_pem.value}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

# Create DNS record
resource "aws_route53_record" "machine_api" {
  zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  name    = "${local.machine_api_fqdn}"
  type    = "A"

  alias = {
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = false
  }
}

# Attach TLS certificate to load balancer
resource "aws_lb_listener_certificate" "machine_api" {
  listener_arn    = "${aws_lb_listener.https_machine_api.arn}"
  certificate_arn = "${aws_acm_certificate.machine_api_cert.arn}"
}

# Create target group for ALB
resource "aws_lb_target_group" "machine_api" {
  name     = "sassy-${var.environment}-machine-api"
  port     = "${local.machine_api_port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"

  health_check {
    path    = "/status"
    matcher = "200-299"
  }
}

# Add HTTPS listener rule
resource "aws_lb_listener_rule" "https_machine_api" {
  listener_arn = "${aws_lb_listener.https_machine_api.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.machine_api.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.machine_api_fqdn}"]
  }
}

# Store SSM parameters for ports, etc
resource "aws_ssm_parameter" "machine_api_origin" {
  name  = "/sassy/${var.environment}/apps/machine-api/origin"
  type  = "String"
  value = "${local.machine_api_origin}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "machine_api_port" {
  name  = "/sassy/${var.environment}/apps/machine-api/port"
  type  = "String"
  value = "${local.machine_api_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}
