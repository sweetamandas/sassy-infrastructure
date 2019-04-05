# SASSY Infrastructure

This project contains all of the infrastructure-as-code modules used to create the SASSY resources on AWS. [Terraform](https://www.terraform.io) is used to define and deploy AWS infrastructure (VPC, databases, servers, etc), and [Packer](https://www.packer.io) is used to define and build the AMI server image that will be deployed on EC2.

## Terraform Details

The SASSY infrastructure code is broken into several Terraform modules, which each handles a specific resource. The `terraform-modules` directory contains the source modules that can be used by individual environments (production, staging, etc). Module variables are used where appropriate to allow different environments to deploy different variations of infrastructure (different instance types, lower availability, etc).

The `terraform-live` directory contains the code that is actually deployed to AWS. The modules in this directory "pull in" modules in the `terraform-modules` and configure them using the variables made available.

Within `terraform-live` there is a `global` directory that contains infrastructure definitions common to all environments, etc, and there are directories for each individual environment.

This repo is set up to use terragrunt. [terragrunt](https://github.com/gruntwork-io/terragrunt) is a helper tool that is used to work with multiple Terraform modules like in this project. See their Github page for a better discussion behind why things are structures as they are.

### Deploying a Module

A certain module can be deployed by go to the respective resource's directory and running `terragrunt apply`:

```bash
cd terraform-live/staging/data-stores/mysql
terragrunt apply
```

At this point terraform will display any changes that will be made, and you can confirm or cancel.

Likewise infrastructure can be destroyed using the `terragrunt destroy` command.

## Packer Details

Packer is used to generate the AMI that will used by any SASSY server instance that is launched. Here are some key notes:

- The `bundle` directory will be copied to the root of the generated AMI. Put any files in here that should be created on the AMI image.
- The `scripts/provision.sh` script will be run on server when the AMI is being generated. You can use this to install dependencies, etc.

To generate a new AMI go the the `ami` directory and run `packer build packer.json`.