locals {
  warehouse_fqdn     = "warehouse${local.subdomain_suffix}.sweetamandas.com"
  warehouse_origin   = "https://${local.warehouse_fqdn}"
  warehouse_port     = 3004
  warehouse_hmr_port = 5004
}

# TLS Certificate using ACM
module "warehouse_cert" {
  source = "./modules/cert-request"

  aws_region     = "${var.aws_region}"
  environment    = "${var.environment}"
  hosted_zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  fqdn           = "${local.warehouse_fqdn}"
}

# Create DNS record
resource "aws_route53_record" "warehouse" {
  zone_id = "${data.terraform_remote_state.dns.primary_hosted_zone_id}"
  name    = "${local.warehouse_fqdn}"
  type    = "A"

  alias = {
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = false
  }
}

# Attach TLS certificate to load balancer
resource "aws_lb_listener_certificate" "warehouse" {
  listener_arn    = "${aws_lb_listener.https.arn}"
  certificate_arn = "${module.warehouse_cert.certificate_arn}"
}

# Create target group for ALB
resource "aws_lb_target_group" "warehouse" {
  name     = "sassy-${var.environment}-warehouse"
  port     = "${local.warehouse_port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"

  health_check {
    path    = "/status"
    matcher = "200-299"
  }
}

# Add HTTP listener rule
resource "aws_lb_listener_rule" "http_warehouse" {
  listener_arn = "${aws_lb_listener.http.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.warehouse.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.warehouse_fqdn}"]
  }
}

# Add HTTPS listener rule
resource "aws_lb_listener_rule" "https_warehouse" {
  listener_arn = "${aws_lb_listener.https.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.warehouse.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.warehouse_fqdn}"]
  }
}

# Store SSM parameters for ports, etc
resource "aws_ssm_parameter" "warehouse_origin" {
  name  = "/sassy/${var.environment}/apps/warehouse/origin"
  type  = "String"
  value = "${local.warehouse_origin}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "warehouse_port" {
  name  = "/sassy/${var.environment}/apps/warehouse/port"
  type  = "String"
  value = "${local.warehouse_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "warehouse_hmr_port" {
  name  = "/sassy/${var.environment}/apps/warehouse/hmr-port"
  type  = "String"
  value = "${local.warehouse_hmr_port}"

  tags = {
    Application = "sassy"
    Environment = "${var.environment}"
  }
}
