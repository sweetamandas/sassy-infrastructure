variable "aws_region" {
  description = "Name of AWS region to deploy in"
}

variable "environment" {
  description = "Name of environment cert will be deployed for"
}

variable "hosted_zone_id" {
  description = "Hosted zone id where cert's domain is"
}

variable "fqdn" {
  description = "FQDN to use for certificate"
}
