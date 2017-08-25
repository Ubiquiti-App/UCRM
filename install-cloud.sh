#!/bin/bash

# This script will install ucrm on a cloud hosted server without any prompt
# Standard ports 80,81,443 will be used
# This script will append all variables in /tmp/cloud_conf (eg. SERVER_NAME) to docker-compose.env

INSTALL_CLOUD=true
CLOUD_CONF="/tmp/cloud_conf"

# Init username and password
UCRM_USERNAME="admin"
UCRM_PASSWORD="admin"
while [[ $# -gt 0 ]]
do
key="$1"
case "${key}" in
  --username)
    UCRM_USERNAME="$2"
    shift # past argument value
    ;;
  --password)
    UCRM_PASSWORD="$2"
    shift # past argument value
    ;;
  *)
    # unknown option
    ;;
esac
shift # past argument key
done
echo "UCRM_USERNAME=${UCRM_USERNAME}" >> "${CLOUD_CONF}"
echo "UCRM_PASSWORD=${UCRM_PASSWORD}" >> "${CLOUD_CONF}"

# Set up swap file
. /tmp/setup-swap.sh

# Install UCRM
. /tmp/install.sh
