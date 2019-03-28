variable "aws_region" {
  description = "Name of AWS region to deploy in"
}

variable "environment" {
  description = "Name of environment VPC will be deployed for"
}

variable "node_type" {
  description = "Type of instance to use for Redis nodes"
}

variable "automatic_failover_enabled" {
  description = "Whether automatic failover is enabled"
}

variable "number_cache_clusters" {
  description = "Number of cache clusters. Must be 2 or more if auto failover is enabled"
}
