#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace

UCRM_PATH="${UCRM_PATH:-}"
if [[ ! -d "${UCRM_PATH}" ]]; then
    UCRM_PATH=""
fi
if [[ "${UCRM_PATH}" = "" ]] && [[ "${BASH_SOURCE+x}" = "x" ]]; then
    UCRM_PATH="$(dirname "${BASH_SOURCE[0]}")"
fi
if [[ "${UCRM_PATH}" = "" ]]; then
    UCRM_PATH="."
fi

if (which realpath > /dev/null 2>&1); then
    UCRM_PATH="$(realpath "${UCRM_PATH}")"
else
    UCRM_PATH="$(cd "${UCRM_PATH}" > /dev/null && pwd)"
fi

export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-Ubiquiti-App/UCRM/master}"

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

if [ ! -w "${UCRM_UPDATES_PATH}" ]; then
    echo "Cannot write into path ${UCRM_UPDATES_PATH}"
    exit 1
fi

UCRM_UPDATE_REQUESTED_FILE="${UCRM_UPDATES_PATH}/update_requested"
UCRM_UPDATE_RUNNING_FILE="${UCRM_UPDATES_PATH}/update_running"
UCRM_UPDATE_MAINTENANCE_FILE="${UCRM_UPDATES_PATH}/update_maintenance"
UCRM_UPDATE_LOG_FILE="${UCRM_UPDATES_PATH}/update.log"

if [[ -f "${UCRM_UPDATE_RUNNING_FILE}" ]]; then
    echo "$(date) --- Update process is already running."

    exit 1
fi

cleanup_old_logs() {
    (find "${UCRM_UPDATES_PATH}/logs" -maxdepth 1 -name 'update_*.log' -type f -printf "${UCRM_UPDATES_PATH}/logs/%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
}

backup_log_file() {
    declare toVersion="${1}"

    if [[ -f "${UCRM_UPDATE_LOG_FILE}" ]]; then
        if [[ ! -d "${UCRM_UPDATES_PATH}/logs" ]]; then
            mkdir -p "${UCRM_UPDATES_PATH}/logs"
        fi

        DATE=$(date +"%s")
        cp -f "${UCRM_UPDATE_LOG_FILE}" "${UCRM_UPDATES_PATH}/logs/update_${toVersion}_${DATE}.log"

        cleanup_old_logs
    fi
}

if [[ -f "${UCRM_UPDATE_REQUESTED_FILE}" ]]; then
    # redirect output to log file
    exec > "${UCRM_UPDATE_LOG_FILE}" 2>&1

    VERSION_TO_UPDATE=$(cat "${UCRM_UPDATE_REQUESTED_FILE}")

    echo "$(date) --- Initializing UCRM update to version ${VERSION_TO_UPDATE}."

    touch "${UCRM_UPDATE_RUNNING_FILE}"
    trap 'rm -f "${UCRM_UPDATE_RUNNING_FILE}"; rm -f "${UCRM_UPDATE_MAINTENANCE_FILE}"; backup_log_file "${VERSION_TO_UPDATE}"; exit' INT TERM EXIT
    rm "${UCRM_UPDATE_REQUESTED_FILE}"

    echo "$(date) --- Downloading current updater."
    curl -o "${UCRM_PATH}/update.sh" "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update.sh"
    export PATH="/usr/local/bin:$PATH"
    echo "$(date) --- Starting the update process."
    if ( bash "${UCRM_PATH}/update.sh" --version "${VERSION_TO_UPDATE}" --cron ); then
        echo "$(date) --- Update successful."
        rm -f "${UCRM_UPDATE_RUNNING_FILE}"
        rm -f "${UCRM_UPDATE_MAINTENANCE_FILE}"
        backup_log_file "${VERSION_TO_UPDATE}"

        exit 0
    else
        echo "$(date) --- Update failed."
        rm -f "${UCRM_UPDATE_RUNNING_FILE}"
        rm -f "${UCRM_UPDATE_MAINTENANCE_FILE}"
        backup_log_file "${VERSION_TO_UPDATE}"

        exit 1
    fi
fi

echo "$(date) --- UCRM update not requested."

exit 0
