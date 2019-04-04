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

environment = "staging"

instance_type = "db.t2.small"

deletion_protection = false

multi_az = false

skip_final_snapshot = true

backup_retention_period = "0"

use_latest_production_snapshot = true
