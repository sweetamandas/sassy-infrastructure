terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "../../../../terraform-modules/apps/sassy"
  }

  dependencies {
    paths = [
      "../../vpc",
      "../../data-stores/s3",
      "../../data-stores/mysql",
      "../../data-stores/redis",
      "../../ses",
    ]
  }
}

aws_region = "us-east-1"

environment = "production"

instance_type = "t2.medium"
