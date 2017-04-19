#!/bin/bash

# This script will install ucrm on a cloud hosted server without any prompt
# Standard ports 80,81,443 will be used
# This script will append all variables in /tmp/cloud_conf (eg. SERVER_NAME) to docker-compose.env

INSTALL_CLOUD=true
CLOUD_CONF="/tmp/cloud_conf"

# Set up 2G swap file (optimized for Ubuntu server on DigitalOcean, 1GB RAM, 20GB disk)
# See https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04
echo "Creating swap file"
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
sysctl vm.swappiness=10
echo "vm.swappiness=10" >> /etc/sysctl.conf
sysctl vm.vfs_cache_pressure=50
echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf
swapon -s
echo "swap file created"

# Install UCRM
. /tmp/install.sh
