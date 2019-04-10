resource "aws_lb" "alb" {
  name               = "sassy-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${data.terraform_remote_state.vpc.alb_security_group_id}"]
  subnets            = ["${data.terraform_remote_state.vpc.public_subnets}"]

  # Set connection timeout to 6 minutes
  idle_timeout = 360

  tags = {
    Environment = "${var.environment}"
    Application = "sassy"
  }
}

# Add listeners to ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.account.arn}"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${module.account_cert.certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.account.arn}"
  }
}

resource "aws_lb_listener" "https_machine_api" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "24267"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.machine_api_cert.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.machine_api.arn}"
  }
}
