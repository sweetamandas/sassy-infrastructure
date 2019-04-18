terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "../../../terraform-modules/vpc"
  }
}

aws_region = "us-east-1"

environment = "development"

mysql_sg_ingress_cidr_blocks = [
  "184.56.214.67/32", // James' house
]
