#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace

UCRM_PATH="${UCRM_PATH:-}"
if [[ "${UCRM_PATH}" = "" ]] && [[ "${BASH_SOURCE+x}" = "x" ]]; then
    UCRM_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
fi
if [[ "${UCRM_PATH}" = "" ]]; then
    UCRM_PATH="."
fi

do_uninstall() {
    if (which docker > /dev/null 2>&1); then
        echo "Removing UCRM docker containers and images."

        if [[ -f "${UCRM_PATH}/docker-compose.yml" ]] && [[ -f "${UCRM_PATH}/docker-compose.migrate.yml" ]]; then
            if [[ -f "${UCRM_PATH}/docker-compose.version.yml" ]]; then
                docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" -f "${UCRM_PATH}/docker-compose.version.yml" stop
                docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" -f "${UCRM_PATH}/docker-compose.version.yml" rm -af
            else
                docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" stop
                docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" rm -af
            fi
        fi

        docker rmi --force $(docker images -a | grep "^ubnt/ucrm-billing" | awk '{print $3}')
    else
        echo "Docker not installed, skipping removal of docker container and images."
    fi

    if [[ -f "${UCRM_PATH}/docker-compose.yml" ]]; then
        echo "Removing ${UCRM_PATH}/docker-compose.yml."
        rm -f "${UCRM_PATH}/docker-compose.yml"
    fi

    if [[ -f "${UCRM_PATH}/docker-compose.migrate.yml" ]]; then
        echo "Removing ${UCRM_PATH}/docker-compose.migrate.yml."
        rm -f "${UCRM_PATH}/docker-compose.migrate.yml"
    fi

    if [[ -f "${UCRM_PATH}/docker-compose.version.yml" ]]; then
        echo "Removing ${UCRM_PATH}/docker-compose.version.yml."
        rm -f "${UCRM_PATH}/docker-compose.version.yml"
    fi

    if [[ -f "${UCRM_PATH}/elasticsearch.yml" ]]; then
        echo "Removing ${UCRM_PATH}/elasticsearch.yml."
        rm -f "${UCRM_PATH}/elasticsearch.yml"
    fi

    if [[ -f "${UCRM_PATH}/docker-compose.env" ]]; then
        echo -e "\n---\n"
        echo "File ${UCRM_PATH}/docker-compose.env is NOT removed and if you want to restore UCRM data in the future, you should do a backup."
        echo "Password for PostgreSQL database is saved in this file and you will not be able to use the current database data without it."
    fi
}

print_intro() {
    echo "+------------------------------------------------+"
    echo "| UCRM - Complete WISP Management Platform       |"
    echo "|                                                |"
    echo "| https://ucrm.ubnt.com/      (uninstaller v1.0) |"
    echo "+------------------------------------------------+"
    echo ""
}

print_intro
do_uninstall
