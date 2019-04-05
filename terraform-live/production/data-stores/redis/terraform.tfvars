terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "../../../../terraform-modules/data-stores/redis"
  }

  dependencies {
    paths = ["../../vpc"]
  }
}

aws_region = "us-east-1"

environment = "production"

node_type = "cache.t2.micro"

automatic_failover_enabled = true

number_cache_clusters = "2"

enable_alerts = true
