#!/bin/bash

# This script will install ucrm on a cloud hosted server without any prompt
# Standard ports 80,81,443 will be used
# This script will append all variables in /tmp/cloud_conf (eg. SERVER_NAME) to docker-compose.env

INSTALL_CLOUD=true
CLOUD_CONF="/tmp/cloud_conf"

. /tmp/install.sh
