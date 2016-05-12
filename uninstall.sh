#!/bin/sh

which docker

if [ $? = 0 ]; then
        docker-compose stop
        docker-compose rm -f -a
        docker rmi --force $(docker images -a | grep "^ubnt/ucrm-billing" | awk '{print $3}')

        echo "Removed U CRM docker containers and images."
else
        echo "Docker not installed, nothing to uninstall."
fi
