#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace

DATE=$(date +"%s")
MIGRATE_OUTPUT=$(mktemp)
FORCE_UPDATE=0
UPDATE_TO_VERSION=""
UPDATING_TO="latest"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-U-CRM/billing/master}"
UCRM_PATH="${UCRM_PATH:-}"
if [[ "${UCRM_PATH}" = "" ]] && [[ "${BASH_SOURCE+x}" = "x" ]]; then
    UCRM_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
fi
if [[ "${UCRM_PATH}" = "" ]]; then
    UCRM_PATH="."
fi

UCRM_USER="${UCRM_USER:-ucrm}"
if [[ -f "${UCRM_PATH}/docker-compose.env" ]]; then
    if ( cat -vt "${UCRM_PATH}/docker-compose.env" | grep -Eq "UCRM_USER=" ); then
        UCRM_USER=$(cat -vt "${UCRM_PATH}/docker-compose.env" | grep -E "UCRM_USER=" --color=never | awk -F= ' {print $NF}')
    fi
fi
NO_AUTO_UPDATE="false"
CRON="false"

NETWORK_SUBNET="${NETWORK_SUBNET:-}"
NETWORK_SUBNET_INTERNAL="${NETWORK_SUBNET_INTERNAL:-}"

trap 'rm -f "${MIGRATE_OUTPUT}"; exit' INT TERM EXIT

download_docker_compose() {
    echo "Downloading and installing Docker Compose."
    curl -L "https://github.com/docker/compose/releases/download/1.14.0/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

install_docker_compose() {
    if ! (which docker-compose > /dev/null 2>&1); then
        download_docker_compose
    fi

    if ! (which docker-compose > /dev/null 2>&1); then
        echo "Docker Compose not installed. Please check previous logs. Aborting."

        exit 1
    fi

    if (cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "networks:") || [[ "${NETWORK_SUBNET}" != "" ]] || [[ "${NETWORK_SUBNET_INTERNAL}" != "" ]]; then
        local DOCKER_COMPOSE_VERSION
        local DOCKER_COMPOSE_MAJOR
        local DOCKER_COMPOSE_MINOR

        DOCKER_COMPOSE_VERSION="$(docker-compose -v | sed 's/.*version \([0-9]*\.[0-9]*\).*/\1/')"
        if [[ "${DOCKER_COMPOSE_VERSION}" != "" ]]; then
            DOCKER_COMPOSE_MAJOR="${DOCKER_COMPOSE_VERSION%.*}"
            DOCKER_COMPOSE_MINOR="${DOCKER_COMPOSE_VERSION#*.}"
        else
            DOCKER_COMPOSE_MAJOR="0"
            DOCKER_COMPOSE_MINOR="0"
        fi

        if [ "${DOCKER_COMPOSE_MAJOR}" -lt 2 ] && [ "${DOCKER_COMPOSE_MINOR}" -lt 9 ] || [ "${DOCKER_COMPOSE_MAJOR}" -lt 1 ]; then
            echo "Docker Compose version ${DOCKER_COMPOSE_VERSION} is not supported. Please upgrade to version 1.9 or newer."
            echo "You can use following commands to upgrade:"
            echo ""
            echo 'sudo curl -L "https://github.com/docker/compose/releases/download/1.14.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'
            echo 'sudo chmod +x /usr/local/bin/docker-compose'
            echo ""

            exit 1
        fi
    fi
}

check_yml() {
    declare file="${1}"
    declare appendFile="${2:-}"
    local size

    size=$(($(wc -c < "${file}")))
    if [[ "${size}" = 0 ]]; then
        echo "File ${file} is invalid. Try running the update script again and if it fails, contact UBNT support."

        exit 1
    fi

    if [[ "${appendFile}" != "" ]]; then
        if ! (docker-compose -f "${file}" -f "${appendFile}" config -q 2>/dev/null); then
            echo "File ${file} is invalid. Try running the update script again and if it fails, contact UBNT support."

            exit 1
        fi
    else
        if ! (docker-compose -f "${file}" config -q 2>/dev/null); then
            echo "File ${file} is invalid. Try running the update script again and if it fails, contact UBNT support."

            exit 1
        fi
    fi
}

compose__backup() {
    echo "Backing up docker compose files."
    if [[ ! -d "${UCRM_PATH}/docker-compose-backups" ]]; then
        mkdir "${UCRM_PATH}/docker-compose-backups"
        chown -R "${UCRM_USER}" "${UCRM_PATH}/docker-compose-backups"
    fi

    if [[ "" != "$(find "${UCRM_PATH}" -maxdepth 1 -name 'docker-compose.env.*.backup' -print -quit)" ]]; then
        mv -f "${UCRM_PATH}/docker-compose.env.*.backup" "${UCRM_PATH}/docker-compose-backups"
    fi

    if [[ "" != "$(find "${UCRM_PATH}" -maxdepth 1 -name 'docker-compose.yml.*.backup' -print -quit)" ]]; then
        mv -f "${UCRM_PATH}/docker-compose.yml.*.backup" "${UCRM_PATH}/docker-compose-backups"
    fi

    cp "${UCRM_PATH}/docker-compose.yml" "${UCRM_PATH}/docker-compose-backups/docker-compose.yml.${DATE}.backup"
    cp "${UCRM_PATH}/docker-compose.env" "${UCRM_PATH}/docker-compose-backups/docker-compose.env.${DATE}.backup"
    if [[ -f "${UCRM_PATH}/docker-compose.migrate.yml" ]]; then
        cp "${UCRM_PATH}/docker-compose.migrate.yml" "${UCRM_PATH}/docker-compose-backups/docker-compose.migrate.yml.${DATE}.backup"
    fi
    if [[ -f "${UCRM_PATH}/docker-compose.version.yml" ]]; then
        cp "${UCRM_PATH}/docker-compose.version.yml" "${UCRM_PATH}/docker-compose-backups/docker-compose.version.yml.${DATE}.backup"
    fi
}

compose__restore() {
    echo "Reverting docker compose files."
    cp -f "${UCRM_PATH}/docker-compose-backups/docker-compose.yml.${DATE}.backup" "${UCRM_PATH}/docker-compose.yml"
    cp -f "${UCRM_PATH}/docker-compose-backups/docker-compose.env.${DATE}.backup" "${UCRM_PATH}/docker-compose.env"
    if [[ -f "${UCRM_PATH}/docker-compose-backups/docker-compose.migrate.yml.${DATE}.backup" ]]; then
        cp -f "${UCRM_PATH}/docker-compose-backups/docker-compose.migrate.yml.${DATE}.backup" "${UCRM_PATH}/docker-compose.migrate.yml"
    fi
    if [[ -f "${UCRM_PATH}/docker-compose-backups/docker-compose.version.yml.${DATE}.backup" ]]; then
        cp -f "${UCRM_PATH}/docker-compose-backups/docker-compose.version.yml.${DATE}.backup" "${UCRM_PATH}/docker-compose.version.yml"
    fi
}

is_updating_to_version() {
    declare to="${1}" required="${2}" allowLatest="${3}" allowBeta="${4:-1}"
    local toVersion

    if [[ "${to}" = "beta" ]]; then
        if [[ "${allowBeta}" = "1" ]]; then
            return 0
        else
            return 1
        fi
    fi

    if [[ "${to}" = "latest" ]]; then
        if [[ "${allowLatest}" = "1" ]]; then
            return 0
        else
            return 1
        fi
    fi

    toVersion=$(echo "${to}" | awk -F. '{ printf("%d%03d%03d\n", $1, $2, $3) }')

    if [[ "${toVersion}" -ge "${required}" ]]; then
        return 0
    fi

    return 1
}

patch__compose__add_elastic_section() {
    if ! ( cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "  elastic:" );
    then
        echo "Your docker-compose doesn't contain Elastic section. Trying to add."
        echo -e "\n\n  elastic:\n    image: elasticsearch:2\n    restart: always" >> "${UCRM_PATH}/docker-compose.yml"
    fi
}

patch__compose__add_elastic_links() {
    if ( cat -vt "${UCRM_PATH}/docker-compose.yml" | tr -d '\n' | grep -Eq "      - postgresql {4}[a-z]" );
    then
        echo "Adding Elastic container links."
        sed -i -e "/      - elastic/d" "${UCRM_PATH}/docker-compose.yml"
        sed -i -e "s/      - postgresql/&\n      - elastic/g" "${UCRM_PATH}/docker-compose.yml"
    fi
}

patch__compose__fix_postgres_restart() {
    if ! ( grep 'image: postgres' -A1 "${UCRM_PATH}/docker-compose.yml" | grep -q "restart" );
    then
        echo "Updating postgres service"
        sed -i -e "s/image: postgres:9.5/&\n    restart: always/g" "${UCRM_PATH}/docker-compose.yml"
    fi
}

patch__compose__fix_elastic_restart() {
    if ! ( grep 'image: elasticsearch' -A1 "${UCRM_PATH}/docker-compose.yml" | grep -q "restart" );
    then
        echo "Updating elastic service"
        sed -i -e "s/image: elasticsearch:2/&\n    restart: always/g" "${UCRM_PATH}/docker-compose.yml"
    fi
}

patch__compose__add_logging() {
    if ! cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "    logging:";
    then
        echo "Updating logging configuration."
        sed -i -e "s/^  [a-z_]\+:$/&\n    logging:\n      driver: \"json-file\"\n      options:\n        max-size: \"10m\"\n        max-file: \"3\"/g" "${UCRM_PATH}/docker-compose.yml"
    fi
}

patch__compose__add_networks() {
    if ! cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "networks:";
    then
        echo "Updating docker-compose.yml networks configuration."
        sed -i -e "s/version: '2'/&\n\nnetworks:\n  public:\n    internal: false\n  internal:\n    internal: true\n/g" "${UCRM_PATH}/docker-compose.yml"

        sed -i -e "s/  postgresql:/&\n    networks:\n      - internal/g" "${UCRM_PATH}/docker-compose.yml"
        sed -i -e "s/  elastic:/&\n    networks:\n      - internal/g" "${UCRM_PATH}/docker-compose.yml"
        sed -i -e "s/  rabbitmq:/&\n    networks:\n      - internal/g" "${UCRM_PATH}/docker-compose.yml"

        sed -i -e "s/  web_app:/&\n    networks:\n      - internal\n      - public/g" "${UCRM_PATH}/docker-compose.yml"
        sed -i -e "s/  supervisord:/&\n    networks:\n      - internal\n      - public/g" "${UCRM_PATH}/docker-compose.yml"
        sed -i -e "s/  sync_app:/&\n    networks:\n      - internal\n      - public/g" "${UCRM_PATH}/docker-compose.yml"
        sed -i -e "s/  crm_search_devices_app:/&\n    networks:\n      - internal\n      - public/g" "${UCRM_PATH}/docker-compose.yml"
        sed -i -e "s/  crm_netflow_app:/&\n    networks:\n      - internal\n      - public/g" "${UCRM_PATH}/docker-compose.yml"
        sed -i -e "s/  crm_ping_app:/&\n    networks:\n      - internal\n      - public/g" "${UCRM_PATH}/docker-compose.yml"
    fi

    if ! cat -vt "${UCRM_PATH}/docker-compose.migrate.yml" | grep -Eq "networks:";
    then
        echo "Updating docker-compose.migrate.yml networks configuration."
        sed -i -e "s/  migrate_app:/&\n    networks:\n      - internal/g" "${UCRM_PATH}/docker-compose.migrate.yml"
    fi
}

patch__compose__configure_network_subnet() {
    if [[ "${NETWORK_SUBNET}" != "" ]]; then
        if (cat -vt "${UCRM_PATH}/docker-compose.yml" | tr -d '\n' | grep -Eq '  public:    internal: false    ipam:      config:        - subnet: '); then
            echo "Subnet is already configured. Please update the docker-compose.yml file manually, if you need to change it."

            exit 1
        else
            patch__compose__add_networks
            sed -i -e "s|    internal: false|&\n    ipam:\n      config:\n        - subnet: ${NETWORK_SUBNET}|g" "${UCRM_PATH}/docker-compose.yml"
        fi
    fi

    if [[ "${NETWORK_SUBNET_INTERNAL}" != "" ]]; then
        if (cat -vt "${UCRM_PATH}/docker-compose.yml" | tr -d '\n' | grep -Eq '  internal:    internal: true    ipam:      config:        - subnet: '); then
            echo "Internal subnet is already configured. Please update the docker-compose.yml file manually, if you need to change it."

            exit 1
        else
            patch__compose__add_networks
            sed -i -e "s|    internal: true|&\n    ipam:\n      config:\n        - subnet: ${NETWORK_SUBNET_INTERNAL}|g" "${UCRM_PATH}/docker-compose.yml"
        fi
    fi
}

patch__compose__download_migrate_file() {
    if [[ ! -f "${UCRM_PATH}/docker-compose.migrate.yml" ]]; then
        echo "Downloading docker compose migrate file."
        curl -o "${UCRM_PATH}/docker-compose.migrate.yml" "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/docker-compose.migrate.yml"
        check_yml "${UCRM_PATH}/docker-compose.migrate.yml" "${UCRM_PATH}/docker-compose.yml"

        return 0
    else
        check_yml "${UCRM_PATH}/docker-compose.migrate.yml" "${UCRM_PATH}/docker-compose.yml"

        return 1
    fi
}

patch__compose__add_search_devices_section() {
    if ! ( cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "  crm_search_devices_app:" );
    then
        echo "Your docker-compose doesn't contain UCRM search devices section. Trying to add."
        echo -e "\n  crm_search_devices_app:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n    command: \"crm_search_devices\"" >> "${UCRM_PATH}/docker-compose.yml"

        return 0
    else
        return 1
    fi
}

patch__compose__add_netflow_section() {
    if ! (cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "  crm_netflow_app:");
    then
        echo "Your docker-compose doesn't contain Netflow section. Trying to add."
        echo -e "\n  crm_netflow_app:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n    ports:\n      - 2055:2055/udp\n    command: \"crm_netflow\"" >> "${UCRM_PATH}/docker-compose.yml"

        return 0
    else
        return 1
    fi
}

patch__compose__add_ping_section() {
    if ! cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "  crm_ping_app:";
    then
        echo "Your docker-compose doesn't contain Ping section. Trying to add."
        echo -e "\n  crm_ping_app:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n    command: \"crm_ping\"" >> "${UCRM_PATH}/docker-compose.yml"

        return 0
    else
        return 1
    fi
}

patch__compose__add_elasticsearch_volumes() {
    if ! cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "/usr/share/elasticsearch/data";
    then
        echo "Updating Elasticsearch volumes configuration."
        sed -i -e "s/image: elasticsearch:2/&\n    volumes:\n      - \.\/data\/elasticsearch:\/usr\/share\/elasticsearch\/data/g" "${UCRM_PATH}/docker-compose.yml"

        return 0
    else
        return 1
    fi
}

patch__compose__add_rabbitmq() {
    if ! (is_updating_to_version "${UPDATING_TO}" "2002002" 1); then
        return 1
    fi

    if ! cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "  rabbitmq:";
    then
        echo "Your docker-compose doesn't contain RabbitMQ and supervisord sections. Trying to add."
        echo -e "\n  rabbitmq:\n    image: rabbitmq:3\n    restart: always\n    volumes:\n      - ./data/rabbitmq:/var/lib/rabbitmq\n\n  supervisord:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n      - elastic\n    command: \"supervisord\"" >> "${UCRM_PATH}/docker-compose.yml"
        echo "Adding RabbitMQ container links."
        sed -i -e "s/      - elastic/&\n      - rabbitmq/g" "${UCRM_PATH}/docker-compose.yml"

        return 0
    else
        return 1
    fi
}

patch__compose__remove_draft_approve() {
    if ! (is_updating_to_version "${UPDATING_TO}" "2003000" 1); then
        return 1
    fi

    if cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "  crm_draft_approve_app:";
    then
        echo "Your docker-compose contains obsolete section crm_draft_approve_app. Trying to remove."
        sed -i -e '/crm_draft_approve_app/,/^  [^ ]/{//!d}' "${UCRM_PATH}/docker-compose.yml"
        sed -i -e '/crm_draft_approve_app/d' "${UCRM_PATH}/docker-compose.yml"

        return 0
    else
        return 1
    fi
}

patch__compose__remove_invoice_send_email() {
    if ! (is_updating_to_version "${UPDATING_TO}" "2003000" 1); then
        return 1
    fi

    if cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "  crm_invoice_send_email_app:";
    then
        echo "Your docker-compose contains obsolete section crm_invoice_send_email_app. Trying to remove."
        sed -i -e '/crm_invoice_send_email_app/,/^  [^ ]/{//!d}' "${UCRM_PATH}/docker-compose.yml"
        sed -i -e '/crm_invoice_send_email_app/d' "${UCRM_PATH}/docker-compose.yml"

        return 0
    else
        return 1
    fi
}

patch__compose__correct_volumes() {
    declare newPath="${1}"

    echo "Correcting volumes path."
    sed -i -e "s/      - .\/data\/ucrm:\/data/${newPath}/g" "${UCRM_PATH}/docker-compose.yml"
    sed -i -e "s/      - .\/data\/ucrm:\/data/${newPath}/g" "${UCRM_PATH}/docker-compose.migrate.yml"
}

patch__compose_env__fix_server_port() {
    if ! grep -q 'SERVER_PORT' "${UCRM_PATH}/docker-compose.env";
    then
        SERVER_PORT=$(grep -A 20 --color=never "web_app" "${UCRM_PATH}/docker-compose.yml" | grep -B 20 --color=never 'command: "server"' | awk '/\-\ ([0-9]+)\:80/{print $2}' | cut -d ':' -f1)
        echo "Adding ${SERVER_PORT} as server port, you can change it in UCRM System > Settings > Application > Server port"
        echo "#used only in installation" >> "${UCRM_PATH}/docker-compose.env"
        echo "SERVER_PORT=${SERVER_PORT}" >> "${UCRM_PATH}/docker-compose.env"
    fi
}

patch__compose_env__fix_suspend_port() {
    if ! grep -q 'SERVER_SUSPEND_PORT' "${UCRM_PATH}/docker-compose.env";
    then
        SERVER_SUSPEND_PORT=$(grep -A 20 --color=never "web_app" "${UCRM_PATH}/docker-compose.yml" | grep -B 20 --color=never 'command: "server"' | awk '/\-\ ([0-9]+)\:81/{print $2}' | cut -d ':' -f1)
        echo "Adding ${SERVER_SUSPEND_PORT} as suspend port, you can change it in UCRM System > Settings > Application > Server suspend port"
        echo "#used only in installation" >> "${UCRM_PATH}/docker-compose.env"
        echo "SERVER_SUSPEND_PORT=${SERVER_SUSPEND_PORT}" >> "${UCRM_PATH}/docker-compose.env"
    fi
}

compose__get_correct_volumes_path() {
    if ! ( cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "\.\/data\/ucrm:\/data" );
    then
        cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -E "^      \- \/home\/.+:\/data$" -m 1 --color=never | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g'
    else
        echo ""
    fi
}

compose__run_update() {
    declare toVersion="${1}"
    local needsVolumesFix
    local volumesPath

    UPDATING_TO="${toVersion}"

    needsVolumesFix=0
    volumesPath=$(compose__get_correct_volumes_path)

    patch__compose__add_elastic_section
    patch__compose__add_elastic_links
    patch__compose__fix_postgres_restart
    patch__compose__fix_elastic_restart
    patch__compose__add_logging

    if patch__compose__download_migrate_file; then
        needsVolumesFix=1
    fi
    if patch__compose__add_search_devices_section; then
        needsVolumesFix=1
    fi
    if patch__compose__add_netflow_section; then
        needsVolumesFix=1
    fi
    if patch__compose__add_ping_section; then
        needsVolumesFix=1
    fi
    if patch__compose__add_elasticsearch_volumes; then
        needsVolumesFix=1
    fi
    if patch__compose__add_rabbitmq; then
        needsVolumesFix=1
    fi

    patch__compose__configure_network_subnet

    patch__compose__remove_draft_approve || true
    patch__compose__remove_invoice_send_email || true

    if [[ "${needsVolumesFix}" = "1" ]] && [[ "${volumesPath}" != "" ]]; then
        patch__compose__correct_volumes "${volumesPath}"
    fi

    patch__compose_env__fix_server_port
    patch__compose_env__fix_suspend_port

    check_yml "${UCRM_PATH}/docker-compose.yml"
}

containers__is_revert_supported() {
    declare version="${1}"

    if [[ "${version}" = "latest" ]] || [[ "${version}" = "beta" ]]; then
        return 0
    elif [[ $(echo "${version}" | awk -F. '{ printf("%d%03d%03d\n", $1, $2, $3); }') -ge 2001005 ]]; then
        return 0
    else
        return 1
    fi
}

containers__revert_update() {
    declare version="${1}"

    compose__restore

    echo "Reverting UCRM to version ${version}"
    containers__run_update "${version}"

    echo "Revert complete."
}

containers__run_update() {
    declare version="${1}"
    local revertVersion

    sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:${version}/g" "${UCRM_PATH}/docker-compose.yml"
    sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:${version}/g" "${UCRM_PATH}/docker-compose.migrate.yml"

    if ! (docker-compose -f "${UCRM_PATH}/docker-compose.yml" pull); then
        if [[ "${FORCE_UPDATE}" = "0" ]]; then
            echo "Image for version \"${version}\" not found."
            compose__restore

            exit 1
        fi
    fi
    docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" stop
    docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" rm -af

    if containers__is_revert_supported "${version}";
    then
        if ( docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" run migrate_app | tee "${MIGRATE_OUTPUT}" );
        then
            docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" rm -af
        else
            revertVersion=$(grep --color=never 'UCRM will be reverted to version' "${MIGRATE_OUTPUT}" | awk ' {print $NF}')
            if [[ "${revertVersion}" != "" ]]; then
                containers__revert_update "${revertVersion}"
            else
                echo "| ########################################################### |"
                echo "|                                                             |"
                echo "|   An error occurred during UCRM update.                     |"
                echo "|   The system can not be reverted to the previous version.   |"
                echo "|   Try to run update script once again or contact support    |"
                echo "|   https://ucrm.ubnt.com/                                    |"
                echo "|                                                             |"
                echo "| ########################################################### |"

                docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" stop
                docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" rm -af

                exit 1
            fi

            return
        fi

    fi

    setup_auto_update
    docker-compose -f "${UCRM_PATH}/docker-compose.yml" up -d --remove-orphans
    docker-compose -f "${UCRM_PATH}/docker-compose.yml" ps
}

confirm_ucrm_running() {
    local ucrmRunning
    local webAppPort

    ucrmRunning=false
    webAppPort=$(grep -A 20 --color=never "web_app" "${UCRM_PATH}/docker-compose.yml" | grep -B 20 --color=never 'command: "server"' | awk '/\-\ ([0-9]+)\:80/{print $2}' | cut -d ':' -f1)
    n=0
    until [ ${n} -ge 10 ]
    do
        sleep 3s
        ucrmRunning=true
        nc -z 127.0.0.1 "${webAppPort}" && break
        echo "."
        ucrmRunning=false
        n=$((n+1))
    done

    if [[ "${ucrmRunning}" = true ]]; then
        printf "\r%-55s\n" "UCRM ready";

        return 0
    else
        printf "\n------------------\nUCRM UPDATE FAILED!\nPlease send update.log to UCRM Community Forum.\n"

        exit 1
    fi
}

detect_update_finished() {
    # print web container log and wait for its initialization
    containerName=$(docker-compose -f "${UCRM_PATH}/docker-compose.yml" ps | grep -m1 "make server" | awk '{print $1}')
    docker exec -t "${containerName}" bash -c 'if [[ ! -f /tmp/UCRM_init.log ]]; then \
    		echo "UCRM is booting now, will be available soon"; \
    	else \
    		echo "Booting UCRM"; spin="-\|/"; i=0; \
    		while true; \
    			do line=$(tail -1 /tmp/UCRM_init.log); \
    			i=$(( (i+1) %4 )); \
    			printf "\r%-45s%s" "$line" "${spin:$i:1}"; \
    			[ "$line" != "UCRM ready" ] || break; \
    			sleep 0.1; \
    		done; \
    		printf "\r%-55s\n" "UCRM ready"; \
    	fi' || confirm_ucrm_running
}

get_from_version() {
    local fromVersion

    if [[ ! -f "${UCRM_PATH}/docker-compose.version.yml" ]]; then
        curl -o "${UCRM_PATH}/docker-compose.version.yml" "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/docker-compose.version.yml"
    fi

    if (cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "networks:") && ! (cat -vt "${UCRM_PATH}/docker-compose.version.yml" | grep -Eq "networks:");
    then
        sed -i -e "s/  get_version_app:/&\n    networks:\n      - internal/g" "${UCRM_PATH}/docker-compose.version.yml"
    fi

    check_yml "${UCRM_PATH}/docker-compose.version.yml" "${UCRM_PATH}/docker-compose.yml"

    currentComposeImage="$(grep -Eo --color=never "ucrm-billing:.+" "${UCRM_PATH}/docker-compose.yml" | head -1 | awk -F: '{print $NF}')"
    sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:${currentComposeImage}/g" "${UCRM_PATH}/docker-compose.version.yml"

    fromVersion=$(docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.version.yml" run get_version_app | tr -d '\n' | grep -Eo --color=never "version:.+" | awk -F: '{print $NF}' | tr -d '[:space:]')
    docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.version.yml" rm -f get_version_app > /dev/null 2>&1

    echo "${fromVersion}"
}

print_update_impossible_msg() {
    declare from="${1}" to="${2}"

    echo "Update from \"${from}\" to \"${to}\" is not possible. You can only update to newer version."
}

print_switch_branches_msg() {
    echo "To switch between branches (e.g. from \"stable\" to \"beta\") you must specify the exact version."
}

check_update_possible() {
    declare from="${1}" to="${2}"
    local fromVersion
    local fromBeta
    local toVersion
    local toBeta

    if [[ "${to}" = "latest" ]]; then
        if (echo "${from}" | grep -q "beta"); then
            print_update_impossible_msg "${from}" "${to}"
            print_switch_branches_msg

            exit 1
        else
            return
        fi
    fi

    if [[ "${to}" = "beta" ]]; then
        if (echo "${from}" | grep -q "beta"); then
            return
        else
            print_update_impossible_msg "${from}" "${to}"
            print_switch_branches_msg

            exit 1
        fi
    fi

    fromVersion=$(echo "${from}" | awk -F. '{ printf("%d%03d%03d\n", $1, $2, $3) }')
    toVersion=$(echo "${to}" | awk -F. '{ printf("%d%03d%03d\n", $1, $2, $3) }')

    if [[ "${toVersion}" -gt "${fromVersion}" ]]; then
        return
    elif [[ "${toVersion}" -lt "${fromVersion}" ]]; then
        print_update_impossible_msg "${from}" "${to}"

        exit 1
    fi

    if (echo "${from}" | grep -q "beta");
    then
        fromBeta=$(echo "${from}" | awk -F'-beta' '{ printf("%d\n", $2) }')
    else
        fromBeta=999
    fi

    if (echo "${to}" | grep -q "beta");
    then
        toBeta=$(echo "${to}" | awk -F'-beta' '{ printf("%d\n", $2) }')
    else
        toBeta=999
    fi

    if [[ "${toBeta}" -ge "${fromBeta}" ]]; then
        return
    fi

    print_update_impossible_msg "${from}" "${to}"

    exit 1
}

cleanup_old_images() {
    local oldImages

    oldImages=$(docker images | grep --color=never "ubnt/ucrm-billing" | grep --color=never "<none>" | awk '{print $3}' | tr '\r\n' ' ' | xargs) || true
    if [[ "${oldImages:-}" != "" ]]; then
        echo "Removing old UCRM images"
        # don't double quote, we need word splitting here
        docker rmi -f ${oldImages} || true
    fi

    if (docker system --help > /dev/null 2>&1);
    then
        echo -e "\n----------------\n"
        echo "We recommend running \"docker system prune\" once in a while to clean unused containers, images, etc."
        echo "You can determine how much space can be cleaned up by running \"docker system df\""
    fi
}

cleanup_old_backups() {
    (find "${UCRM_PATH}" -maxdepth 1 -name 'docker-compose.env.*.backup' -type f -printf "%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
    (find "${UCRM_PATH}" -maxdepth 1 -name 'docker-compose.yml.*.backup' -type f -printf "%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
    (find "${UCRM_PATH}" -maxdepth 1 -name 'docker-compose.migrate.yml.*.backup' -type f -printf "%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
    (find "${UCRM_PATH}" -maxdepth 1 -name 'docker-compose.version.yml.*.backup' -type f -printf "%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
    (find "${UCRM_PATH}/docker-compose-backups" -maxdepth 1 -name 'docker-compose.env.*.backup' -type f -printf "%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
    (find "${UCRM_PATH}/docker-compose-backups" -maxdepth 1 -name 'docker-compose.yml.*.backup' -type f -printf "%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
    (find "${UCRM_PATH}/docker-compose-backups" -maxdepth 1 -name 'docker-compose.migrate.yml.*.backup' -type f -printf "%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
    (find "${UCRM_PATH}/docker-compose-backups" -maxdepth 1 -name 'docker-compose.version.yml.*.backup' -type f -printf "%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
}

cleanup_auto_update() {
    UCRM_DATA_PATH=$(get_ucrm_data_path)
    UCRM_UPDATE_RUNNING_FILE="${UCRM_DATA_PATH}/updates/update_running"

    if [[ -f "${UCRM_UPDATE_RUNNING_FILE}" ]]; then
        rm -f "${UCRM_UPDATE_RUNNING_FILE}"
    fi
}

flush_udp_conntrack() {
    docker run --net=host --privileged --rm ubnt/ucrm-conntrack
}

get_ucrm_data_path() {
    if ! ( cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "\.\/data\/ucrm:\/data" );
    then
        cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -E "^      \- \/home\/.+:\/data$" -m 1 --color=never | awk ' {print $NF}' | awk -F: '{print $1}'
    else
        echo "data/ucrm"
    fi
}

configure_auto_update_permissions() {
    if ! (is_updating_to_version "${UPDATING_TO}" "2006000" 1 1); then
        return 0
    fi

    if [[ "${NO_AUTO_UPDATE}" = "true" ]] || [[ "${CRON}" = "true" ]]; then
        echo "Skipping auto-update permissions setup."
    else
        echo "Configuring auto-update permissions."

        UCRM_DATA_PATH=$(get_ucrm_data_path)
        UCRM_UPDATES_PATH="${UCRM_DATA_PATH}/updates"

        chown "${UCRM_USER}" "${UCRM_PATH}"
        if [[ "${UCRM_DATA_PATH}" = "data/ucrm" ]]; then
            chown "${UCRM_USER}" "data"
        fi
        chown "${UCRM_USER}" "${UCRM_DATA_PATH}"

        if [[ ! -d "${UCRM_UPDATES_PATH}" ]]; then
            mkdir -p "${UCRM_UPDATES_PATH}"
            chown -R "${UCRM_USER}" "${UCRM_UPDATES_PATH}"
        fi

        if [[ -d "${UCRM_PATH}/docker-compose-backups" ]]; then
            chown -R "${UCRM_USER}" "${UCRM_PATH}/docker-compose-backups"
        fi

        chown -R "${UCRM_USER}" "${UCRM_UPDATES_PATH}"
        chown -R "${UCRM_USER}" "${UCRM_DATA_PATH}" || true

        if [[ -f "${UCRM_PATH}/docker-compose.yml" ]]; then
            chown "${UCRM_USER}" "${UCRM_PATH}/docker-compose.yml"
        fi

        if [[ -f "${UCRM_PATH}/docker-compose.migrate.yml" ]]; then
            chown "${UCRM_USER}" "${UCRM_PATH}/docker-compose.migrate.yml"
        fi

        if [[ -f "${UCRM_PATH}/docker-compose.version.yml" ]]; then
            chown "${UCRM_USER}" "${UCRM_PATH}/docker-compose.version.yml"
        fi

        if [[ -f "${UCRM_PATH}/docker-compose.env" ]]; then
            chown "${UCRM_USER}" "${UCRM_PATH}/docker-compose.env"
        fi

        if [[ -f "${UCRM_PATH}/update.sh" ]]; then
            chown "${UCRM_USER}" "${UCRM_PATH}/update.sh"
        fi
    fi
}

setup_auto_update() {
    if ! (is_updating_to_version "${UPDATING_TO}" "2006000" 1 1); then
        return 0
    fi

    if [[ "${NO_AUTO_UPDATE}" = "true" ]]; then
        echo "Skipping auto-update setup."
    else
        echo "Configuring auto-update."

        if crontab -l -u "${UCRM_USER}"; then
            if ! crontab -u "${UCRM_USER}" -r; then
                echo "Failed to clean crontab."

                exit 1
            fi
        fi

        UPDATE_CRON_SCRIPT="${UCRM_PATH}/update-cron.sh"
        curl -o "${UPDATE_CRON_SCRIPT}" "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/update-cron.sh"

        if ! (chown "${UCRM_USER}" "${UPDATE_CRON_SCRIPT}"); then
          echo "Failed to setup auto-update script."

          exit 1
        fi

        if ! (chmod +x "${UPDATE_CRON_SCRIPT}"); then
          echo "Failed to setup auto-update script."

          exit 1
        fi

        if ! (crontab -l -u "${UCRM_USER}"; echo "* * * * * ${UPDATE_CRON_SCRIPT} > /dev/null 2>&1 || true") | crontab -u "${UCRM_USER}" -; then
          echo "Failed to setup auto-update cron job."

          exit 1
        fi
    fi
}

do_update() {
    declare toVersion="${1}"
    UPDATING_TO="${toVersion}"

    install_docker_compose
    configure_auto_update_permissions
    compose__backup
    compose__run_update "${toVersion}"
    containers__run_update "${toVersion}"
    flush_udp_conntrack || true
    detect_update_finished

    cleanup_old_images
    cleanup_old_backups
    cleanup_auto_update
}

main() {
    declare toVersion="${1}"
    local fromVersion

    install_docker_compose
    fromVersion=$(get_from_version)
    fromVersion="${fromVersion:-latest}"
    if [[ "${toVersion}" = "" ]]; then
        if (echo "${fromVersion}" | grep -q "beta");
        then
            toVersion="beta"
        else
            toVersion="latest"
        fi
    else
        check_update_possible "${fromVersion}" "${toVersion}"
    fi

    do_update "${toVersion}"

    exit 0
}

print_intro() {
    echo "+------------------------------------------------+"
    echo "| UCRM - Complete WISP Management Platform       |"
    echo "|                                                |"
    echo "| https://ucrm.ubnt.com/          (updater v1.7) |"
    echo "+------------------------------------------------+"
    echo ""
}
print_intro

while [[ $# -gt 0 ]]
do
key="$1"

case "${key}" in
  -v|--version)
    echo "Setting UPDATE_TO_VERSION=$2"
    UPDATE_TO_VERSION="$2"
    shift # past argument value
    ;;
  --subnet)
    echo "Setting NETWORK_SUBNET=$2"
    NETWORK_SUBNET="$2"
    shift # past argument value
    ;;
  --subnet-internal)
    echo "Setting NETWORK_SUBNET_INTERNAL=$2"
    NETWORK_SUBNET_INTERNAL="$2"
    shift # past argument value
    ;;
  -f|--force)
    echo "Setting FORCE_UPDATE=1"
    FORCE_UPDATE=1
    ;;
  --no-auto-update)
    echo "Setting NO_AUTO_UPDATE=true"
    NO_AUTO_UPDATE="true"
    ;;
  --cron)
    echo "Setting CRON=true"
    CRON="true"
    ;;
  *)
    echo "Setting UPDATE_TO_VERSION=$1"
    UPDATE_TO_VERSION="$1"
    ;;
esac
shift # past argument key
done

if [[ "${FORCE_UPDATE}" = "1" ]] && [[ "${UPDATE_TO_VERSION}" != "" ]]; then
    do_update "${UPDATE_TO_VERSION}"
else
    main "${UPDATE_TO_VERSION}"
fi
