variable "aws_region" {
  description = "Name of AWS region to deploy in"
}

variable "environment" {
  description = "Name of environment VPC will be deployed for"
}

variable "instance_type" {
  description = "Type of instance to use for MySQL database"
}

variable "deletion_protection" {
  description = "Whether database deletion protection is enabled"
}

variable "multi_az" {
  description = "Whether database uses multi availability zones"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
}

variable "backup_retention_period" {
  description = "Number of days to retain backups for. 0 to disable backups"
}
