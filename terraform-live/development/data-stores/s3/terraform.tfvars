terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "../../../../terraform-modules/data-stores/s3"
  }
}

aws_region = "us-east-1"

environment = "development"
