variable "aws_region" {
  description = "Name of AWS region to deploy in"
}

variable "environment" {
  description = "Name of environment VPC will be deployed for"
}

variable "max_az_count" {
  description = "Maximum number of availability zones that subnets will be created in"
  default     = 3
}
