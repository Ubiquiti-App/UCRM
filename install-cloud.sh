#!/bin/bash

# This script will install ucrm on a cloud hosted server without any promt
# Standard ports 80,81,443 will be used
# This script requires the variable SERVER_NAME to be defined

INSTALL_CLOUD=true
if [ -z "$SERVER_NAME" ]; then SERVER_NAME=""; fi

. /tmp/install.sh
