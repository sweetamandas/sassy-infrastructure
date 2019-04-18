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

variable "mysql_sg_ingress_cidr_blocks" {
  description = "Additional CIDR blocks that can access MySQL instances"
  default     = []
}
