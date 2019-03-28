terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "../../../terraform-modules/vpc"
  }
}

aws_region = "us-east-1"

environment = "staging"
