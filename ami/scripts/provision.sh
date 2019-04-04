#!/bin/bash

# This script is run on the build server and installs all necessary files,
# packages, etc

set -o errexit

# Initialize nodesource repo
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -


# Initialize yarn package manager repo
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Note: Ubuntu 17.04 comes with cmdtest installed by default. If you’re getting
# errors from installing yarn, you may want to run sudo apt remove cmdtest
# first.
sudo apt remove cmdtest

# Update and install packages
sudo apt-get update
sudo apt-get -yq upgrade
sudo apt-get -yq install git awscli nodejs yarn wget gcc libsystemd-dev

# Extract bundle files
sudo tar -C / -zxvpof /tmp/bundle.tar.gz && rm /tmp/bundle.tar.gz

# Update home dir permissions
sudo chown -R ubuntu:ubuntu /home/ubuntu

# Make sure all scripts are executable
chmod -R +x /home/ubuntu/scripts

# Initialize repos for apps
mkdir /home/ubuntu/sassy
cd /home/ubuntu/sassy
git init
git remote add origin git@github.com:sweetamandas/sassy.git

mkdir /home/ubuntu/quickbooks-export
cd /home/ubuntu/quickbooks-export
git init
git remote add origin git@github.com:sweetamandas/quickbooks-export.git

# Install go and build journald-cloudwatch logs manager
cd /home/ubuntu
wget https://dl.google.com/go/go1.12.1.linux-amd64.tar.gz
tar -xvf go1.12.1.linux-amd64.tar.gz
sudo mv go /usr/local

export GOROOT=/usr/local/go
export GOPATH=/home/ubuntu/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

mkdir -p /home/ubuntu/go/src
cd /home/ubuntu/go/src
git clone https://github.com/saymedia/journald-cloudwatch-logs.git
cd journald-cloudwatch-logs
go build -o journald-cloudwatch-logs
sudo mv journald-cloudwatch-logs /usr/local/bin/journald-cloudwatch-logs

# Create state dir
sudo mkdir -p /var/lib/journald-cloudwatch-logs

# Enable services
sudo systemctl enable journald-cloudwatch-logs.service
sudo systemctl enable git-pull.service
sudo systemctl enable get-environment.service
sudo systemctl enable sassy-account.service
sudo systemctl enable sassy-dashboard.service
sudo systemctl enable sassy-warehouse.service
sudo systemctl enable sassy-partners.service
sudo systemctl enable sassy-technicians.service
sudo systemctl enable sassy-machine-api.service
sudo systemctl enable quickbooks-export.service

