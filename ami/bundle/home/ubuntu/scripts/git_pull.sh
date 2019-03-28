#!/bin/bash

# Run git command using git public key pulled from AWS SSM parameter store.
# See https://alestic.com/2018/12/aws-ssm-parameter-store-git-key/ for more
# details
git-with-ssm-key() {

  ssh-agent bash -o pipefail -c '
    ssm_key=/github-ssh-keys/sassy-deploy
    az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    region=$(echo "$az" | sed 's/[a-z]$//')
    if aws ssm get-parameter \
         --region "$region" \
         --with-decryption \
         --name "$ssm_key" \
         --output text \
         --query Parameter.Value |
       ssh-add -q -
    then
      git "$@"
    else
      echo >&2 "ERROR: Failed to get or add key: '$ssm_key'"
      exit 1
    fi
  ' bash "$@"
}

set -o errexit

# Pull latest app versions down from github
cd /home/ubuntu/sassy
git-with-ssm-key pull origin refactor
yarn install

cd /home/ubuntu/quickbooks-export
git-with-ssm-key pull origin master
yarn install