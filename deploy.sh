#!/bin/bash

# Usage: ./deploy.sh [host]

host="${1:-ubuntu@opinionatedprogrammer.com}"

# The host key might change when we instantiate a new VM, so
# we remove (-R) the old host key from known_hosts
ssh-keygen -R "${host#*@}" 2> /dev/null

ssh -o 'StrictHostKeyChecking no' "$host" '
sudo apt-get install -y git-core &&
sudo rm -rf ~/chef &&
git clone https://github.com/bashou/chef-solo.git chef &&
cd ~/chef &&
sudo bash install.sh'