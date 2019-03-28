# Terragrunt is a thin wrapper for Terraform that provides extra tools for
# working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
terragrunt = {
  # Configure Terragrunt to automatically store tfstate files in an S3 bucket
  remote_state {
    backend = "s3"

    config {
      bucket  = "sweetamandas-terraform-state"
      key     = "sassy/${path_relative_to_include()}/terraform.tfstate"
      region  = "us-east-1"
      encrypt = true
    }
  }
}
