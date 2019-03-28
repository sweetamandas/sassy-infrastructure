variable "aws_region" {
  description = "Name of AWS region to deploy in"
}

variable "environment" {
  description = "Name of environment cert will be deployed for"
}

variable "instance_type" {
  description = "EC2 instance type to use for autoscaling group"
}
