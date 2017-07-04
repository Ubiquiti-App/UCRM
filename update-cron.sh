#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace

UCRM_USER="${UCRM_USER:-ucrm}"
UCRM_PATH="${UCRM_PATH:-/home/${UCRM_USER}}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-U-CRM/billing/master}"

if [[ ! -f "${UCRM_PATH}/docker-compose.yml" ]]; then
    echo "docker-compose.yml does not exist or is not readable in path ${UCRM_PATH}"

    exit 1
fi

get_ucrm_data_path() {
    if ! ( cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "\.\/data\/ucrm:\/data" );
    then
        cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -E "^      \- \/home\/.+:\/data$" -m 1 --color=never | awk ' {print $NF}' | awk -F: '{print $1}'
    else
        echo "${UCRM_PATH}/data/ucrm"
    fi
}
UCRM_DATA_PATH=$(get_ucrm_data_path)
UCRM_UPDATES_PATH="${UCRM_DATA_PATH}/updates"

if [[ ! -d "${UCRM_UPDATES_PATH}" ]]; then
    mkdir -p "${UCRM_UPDATES_PATH}"
fi
UCRM_UPDATE_REQUESTED_FILE="${UCRM_UPDATES_PATH}/update_requested"
UCRM_UPDATE_RUNNING_FILE="${UCRM_UPDATES_PATH}/update_running"
UCRM_UPDATE_LOG_FILE="${UCRM_UPDATES_PATH}/update.log"

if [[ -f "${UCRM_UPDATE_RUNNING_FILE}" ]]; then
    echo "$(date) --- Update process is already running."

    exit 1
fi

if [[ -f "${UCRM_UPDATE_REQUESTED_FILE}" ]]; then
    # redirect output to log file
    exec > ${UCRM_UPDATE_LOG_FILE} 2>&1

    VERSION_TO_UPDATE=$(cat "${UCRM_UPDATE_REQUESTED_FILE}")
    echo "$(date) --- Initializing UCRM update to version ${VERSION_TO_UPDATE}."

    touch "${UCRM_UPDATE_RUNNING_FILE}"
    trap 'rm -f "${UCRM_UPDATE_RUNNING_FILE}"; exit' INT TERM EXIT
    rm "${UCRM_UPDATE_REQUESTED_FILE}"

    cd "${UCRM_PATH}"
    echo "$(date) --- Downloading current updater."
    curl -o update.sh "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update.sh"
    export PATH="/usr/local/bin:$PATH"
    echo "$(date) --- Starting the update process."
    if ( bash update.sh --version "${VERSION_TO_UPDATE}" --cron ); then
        echo "$(date) --- Update successful."

        exit 0
    else
        echo "$(date) --- Update failed."

        exit 1
    fi
fi

echo "$(date) --- UCRM update not requested."

exit 0
