module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.9.1"

  name = "sassy-${var.environment}"

  # Launch configuration
  lc_name = "sassy-${var.environment}-lc"

  image_id             = "ami-0725ff8e5c08e91bc"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${data.terraform_remote_state.vpc.server_security_group_id}"]
  iam_instance_profile = "${aws_iam_instance_profile.profile.name}"

  # Auto scaling group
  asg_name                  = "sassy-${var.environment}-asg"
  vpc_zone_identifier       = ["${data.terraform_remote_state.vpc.public_subnets}"]
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  target_group_arns = [
    "${aws_lb_target_group.account.arn}",
    "${aws_lb_target_group.dashboard.arn}",
    "${aws_lb_target_group.partners.arn}",
    "${aws_lb_target_group.machine_api.arn}",
    "${aws_lb_target_group.technicians.arn}",
    "${aws_lb_target_group.warehouse.arn}",
  ]

  tags = [
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "Application"
      value               = "sassy"
      propagate_at_launch = true
    },
  ]
}
