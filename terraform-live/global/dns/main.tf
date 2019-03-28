provider "aws" {
  region  = "us-east-1"
  version = "~> 1.59"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}
