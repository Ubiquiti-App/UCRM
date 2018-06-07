#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace

UCRM_PATH="${UCRM_PATH:-}"
if [ ! -d "${UCRM_PATH}" ]; then
    UCRM_PATH=""
fi
if [[ "${UCRM_PATH}" = "" ]] && [[ "${BASH_SOURCE+x}" = "x" ]]; then
    UCRM_PATH="$(dirname "${BASH_SOURCE[0]}")"
fi
if [[ "${UCRM_PATH}" = "" ]]; then
    UCRM_PATH="."
fi

REALPATH="$(which realpath)"
if [ "$REALPATH" != "" ] && [ -x "$REALPATH" ]; then
    UCRM_PATH="$(${REALPATH} "${UCRM_PATH}")"
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
UCRM_UPDATE_RUNNING_LOCK_DIR="${UCRM_UPDATES_PATH}/update_running"
UCRM_UPDATE_LOG_FILE="${UCRM_UPDATES_PATH}/update.log"

# mkdir lock_dir is atomic, test -f lock_file && touch lock_file has a race condition
if ( mkdir "${UCRM_UPDATE_RUNNING_LOCK_DIR}" ); then
    trap 'rm -rf "${UCRM_UPDATE_RUNNING_LOCK_DIR}"; exit' INT TERM EXIT
else
    echo "$(date) --- Update process is already running."

    exit 1
fi

if [[ -f "${UCRM_UPDATE_REQUESTED_FILE}" ]]; then
    # redirect output to log file
    exec > "${UCRM_UPDATE_LOG_FILE}" 2>&1

    VERSION_TO_UPDATE=$(cat "${UCRM_UPDATE_REQUESTED_FILE}")
    echo "$(date) --- Initializing UCRM update to version ${VERSION_TO_UPDATE}."

    rm "${UCRM_UPDATE_REQUESTED_FILE}"

    echo "$(date) --- Downloading current updater."
    curl -o "${UCRM_PATH}/update.sh" "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update.sh"
    export PATH="/usr/local/bin:$PATH"
    echo "$(date) --- Starting the update process."
    export UCRM_PATH
    if ( bash "${UCRM_PATH}/update.sh" --version "${VERSION_TO_UPDATE}" --cron ); then
        echo "$(date) --- Update successful."

        exit 0
    else
        echo "$(date) --- Update failed."

        exit 1
    fi
fi

echo "$(date) --- UCRM update not requested."

exit 0
