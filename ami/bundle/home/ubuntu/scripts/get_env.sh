#!/bin/bash

# Get environment from EC2 tags and save NODE_ENV to file

az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
region=$(echo "$az" | sed 's/[a-z]$//')

instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
environment=$(aws ec2 describe-tags \
  --filters "Name=resource-id,Values=$instance_id" \
  --query 'Tags[?contains(Key, `Environment`)].Value' \
  --output text \
  --region "$region")

echo "NODE_ENV=${environment}" > /home/ubuntu/env
echo "ENVIRONMENT=${environment}" >> /home/ubuntu/env