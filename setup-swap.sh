#!/bin/bash

# Set up 2G swap file (optimized for Ubuntu server on DigitalOcean, 1GB RAM, 20GB disk)
# See https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04
# must be executed with root privileges

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

swapoff -a
swapon -a
swapon -s

echo "swap file created"
