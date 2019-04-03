terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "../../../../terraform-modules/data-stores/mysql"
  }

  dependencies {
    paths = ["../../vpc"]
  }
}

aws_region = "us-east-1"

environment = "production"

instance_type = "db.t2.small"

deletion_protection = true

multi_az = true

skip_final_snapshot = false

backup_retention_period = "30"
