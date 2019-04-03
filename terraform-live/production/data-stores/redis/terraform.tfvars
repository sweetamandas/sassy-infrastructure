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

automatic_failover_enabled = "1"

number_cache_clusters = "1"
