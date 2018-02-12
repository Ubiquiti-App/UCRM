#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace

SECURE_FIRST_LOGIN="false"
NO_AUTO_UPDATE="false"
SKIP_SYSTEM_SETUP="false"

while [[ $# -gt 0 ]]
do
key="$1"

case "${key}" in
  -v|--version)
    echo "Setting INSTALL_VERSION=$2"
    INSTALL_VERSION="$2"
    shift # past argument value
    ;;
  --http-port)
    echo "Setting PORT_HTTP=$2"
    PORT_HTTP="$2"
    shift # past argument value
    ;;
  --https-port)
    echo "Setting PORT_HTTPS=$2"
    PORT_HTTPS="$2"
    shift # past argument value
    ;;
  --suspension-port)
    echo "Setting PORT_SUSPENSION=$2"
    PORT_SUSPENSION="$2"
    shift # past argument value
    ;;
  --netflow-port)
    echo "Setting PORT_NETFLOW=$2"
    PORT_NETFLOW="$2"
    shift # past argument value
    ;;
  --ucrm-user)
    echo "Setting UCRM_USER=$2"
    UCRM_USER="$2"
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
  --skip-system-setup)
    echo "Setting SKIP_SYSTEM_SETUP=true"
    SKIP_SYSTEM_SETUP="true"
    ;;
  --no-auto-update)
    echo "Setting NO_AUTO_UPDATE=true"
    NO_AUTO_UPDATE="true"
    ;;
  --secure-first-login)
    echo "Setting SECURE_FIRST_LOGIN=true"
    SECURE_FIRST_LOGIN="true"
    ;;
  *)
    # unknown option
    ;;
esac
shift # past argument key
done

UCRM_USER="${UCRM_USER:-ucrm}"
UCRM_PATH="${UCRM_PATH:-/home/${UCRM_USER}}"
UCRM_USERNAME=""
UCRM_PASSWORD=""
INSTALL_VERSION="${INSTALL_VERSION:-latest}"

POSTGRES_PASSWORD="$(LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom | fold -w 48 | head -n 1 || true)"
SECRET="$(LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom | fold -w 48 | head -n 1 || true)"
INSTALL_CLOUD="${INSTALL_CLOUD:-false}"

GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-Ubiquiti-App/UCRM/master}"

if [[ -f "${UCRM_PATH}/docker-compose.env" ]]; then
    if ( cat -vt "${UCRM_PATH}/docker-compose.env" | grep -Eq "PORT_HTTP=" ); then
        PORT_HTTP=$(cat -vt "${UCRM_PATH}/docker-compose.env" | grep -E "PORT_HTTP=" --color=never | awk -F= ' {print $NF}')
    fi
    if ( cat -vt "${UCRM_PATH}/docker-compose.env" | grep -Eq "PORT_SUSPENSION=" ); then
        PORT_SUSPENSION=$(cat -vt "${UCRM_PATH}/docker-compose.env" | grep -E "PORT_SUSPENSION=" --color=never | awk -F= ' {print $NF}')
    fi
    if ( cat -vt "${UCRM_PATH}/docker-compose.env" | grep -Eq "PORT_HTTPS=" ); then
        PORT_HTTPS=$(cat -vt "${UCRM_PATH}/docker-compose.env" | grep -E "PORT_HTTPS=" --color=never | awk -F= ' {print $NF}')
    fi
fi

NETWORK_SUBNET="${NETWORK_SUBNET:-}"
NETWORK_SUBNET_INTERNAL="${NETWORK_SUBNET_INTERNAL:-}"
PORT_HTTP="${PORT_HTTP:-80}"
PORT_SUSPENSION="${PORT_SUSPENSION:-81}"
PORT_HTTPS="${PORT_HTTPS:-443}"
PORT_NETFLOW="${PORT_NETFLOW:-2055}"
ALTERNATIVE_PORT_HTTP="${ALTERNATIVE_PORT_HTTP:-8080}"
ALTERNATIVE_PORT_SUSPENSION="${ALTERNATIVE_PORT_SUSPENSION:-8081}"
ALTERNATIVE_PORT_HTTPS="${ALTERNATIVE_PORT_HTTPS:-8443}"
ALTERNATIVE_PORT_NETFLOW="${ALTERNATIVE_PORT_NETFLOW:-2056}"

version_equal_or_newer() {
    if [[ "$1" == "$2" ]]; then return 0; fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do ver1[i]=0; done
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then ver2[i]=0; fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then return 0; fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then return 1; fi
    done
    return 0;
}

is_updating_to_version() {
    declare to="${1}" required="${2}" allowLatest="${3}" allowBeta="${4}"
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

check_system() {
    local architecture
    architecture="$(uname -m)"
    case "${architecture}" in
        amd64|x86_64)
            ;;
        *)
            echo "Your architecture (${architecture}) is not supported."
            echo "Check https://ucrm.ubnt.com/#minimum-system-requirements for minimum system requirements."
            exit 1
            ;;
    esac

    local lsb_dist
    local dist_version

    if [[ "" = "${lsb_dist:-}" ]] && [[ -r /etc/lsb-release ]]; then
        lsb_dist="$(. /etc/lsb-release && echo "${DISTRIB_ID:-}")"
    fi

    if [[ "" = "${lsb_dist:-}" ]] && [[ -r /etc/debian_version ]]; then
        lsb_dist="debian"
    fi

    if [[ "" = "${lsb_dist:-}" ]] && [[ -r /etc/fedora-release ]]; then
        lsb_dist="fedora"
    fi

    if [[ "" = "${lsb_dist:-}" ]] && [[ -r /etc/oracle-release ]]; then
        lsb_dist="oracleserver"
    fi

    if [[ "" = "${lsb_dist:-}" ]]; then
        if [[ -r /etc/centos-release ]] || [[ -r /etc/redhat-release ]]; then
        lsb_dist="centos"
        fi
    fi

    if [[ "" = "${lsb_dist:-}" ]] && [[ -r /etc/os-release ]]; then
        lsb_dist="$(. /etc/os-release && echo "${ID:-}")"
    fi

    lsb_dist="$(echo "${lsb_dist:-}" | tr '[:upper:]' '[:lower:]')"

    local supported_distribution=false
    case "${lsb_dist}" in
      ubuntu)
          if [[ "" = "${dist_version:-}" ]] && [[ -r /etc/lsb-release ]]; then
              dist_version="$(. /etc/lsb-release && echo "${DISTRIB_RELEASE:-}")"
          fi
          if version_equal_or_newer "${dist_version}" "16.04"; then
            supported_distribution=true
          fi
          ;;

      debian)
          dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
          if version_equal_or_newer "${dist_version}" "8"; then
            supported_distribution=true
          fi
          ;;

      *)
          if [[ "" = "${dist_version:-}" ]] && [[ -r /etc/os-release ]]; then
            dist_version="$(. /etc/os-release && echo "${VERSION_ID:-}")"
          fi
          ;;
    esac

    if [[ "${supported_distribution}" != true ]]; then
        echo "Your OS (${lsb_dist} ${dist_version}) is not officially supported."
        echo "Check https://ucrm.ubnt.com/#minimum-system-requirements for minimum system requirements."

        local continueUnsupported

        while true; do
            read -r -p "Do you still wish to continue? [Y/n]: " continueUnsupported

            case "${continueUnsupported}" in
                [yY][eE][sS]|[yY])
                    return 0
                    break;;
                [nN][oO]|[nN])
                    exit 1
                    break;;
                *)
                    ;;
            esac
        done
    fi

    if [[ -e /proc/meminfo ]]; then
        local memory
        local memoryUnit
        memory="$(awk '/MemTotal/{print $2}' /proc/meminfo)"
        if (which bc > /dev/null 2>&1); then
            memoryUnit=$(echo "scale=2; ${memory}/1024^2" | bc)
            memoryUnit="${memoryUnit} GB"
        else
            memoryUnit="${memory} KB"
        fi

        if [[ "${memory}" -lt 2000000 ]]; then
            echo "WARNING: Your system has only ${memoryUnit} RAM."
            echo "We recommend at least 2 GB RAM to run UCRM without problems."
        fi
    fi
}

install_docker() {
    if ! (which docker > /dev/null 2>&1); then
        echo "Downloading and installing Docker."
        curl -fsSL https://get.docker.com/ | sh
    fi

    if ! (which docker > /dev/null 2>&1); then
        echo "Docker not installed. Please check previous logs. Aborting."

        exit 1
    fi
}

download_docker_compose() {
    echo "Downloading and installing Docker Compose."
    curl -L "https://github.com/docker/compose/releases/download/1.16.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
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

    if [[ "${NETWORK_SUBNET}" != "" ]] || [[ "${NETWORK_SUBNET_INTERNAL}" != "" ]]; then
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
            local DO_UPDATE_DOCKER_COMPOSE

            while true; do
                read -r -p "Would you like to upgrade Docker Compose automatically? [Y/n]: " DO_UPDATE_DOCKER_COMPOSE

                case "${DO_UPDATE_DOCKER_COMPOSE}" in
                    [yY][eE][sS]|[yY])
                        download_docker_compose
                        break;;
                    [nN][oO]|[nN])
                        exit 1
                        break;;
                    *)
                        ;;
                esac
            done
        fi
    fi
}

create_user() {
    if (which getent > /dev/null 2>&1); then
        if [ -z "$(getent passwd "${UCRM_USER}")" ]; then
            echo "Creating user ${UCRM_USER}."
            if (which adduser > /dev/null 2>&1); then
                adduser --disabled-password --gecos "" "${UCRM_USER}" || true
            elif (which useradd > /dev/null 2>&1); then
                useradd "${UCRM_USER}" || true
            fi
            usermod -aG docker "${UCRM_USER}" || true
        fi
    fi

    if (which groups > /dev/null 2>&1); then
        if ! (groups "${UCRM_USER}" 2>/dev/null | grep -q "docker"); then
            echo "Adding user \"${UCRM_USER}\" to \"docker\" group."
            usermod -aG docker "${UCRM_USER}" || true
        fi
    fi

    if [[ ! -d "${UCRM_PATH}" ]]; then
        echo "Creating directory ${UCRM_PATH}."
        mkdir -p "${UCRM_PATH}"
    fi
}

download_docker_compose_files() {
    if [ ! -f "${UCRM_PATH}/docker-compose.yml" ]; then
        echo "Downloading docker compose files."
        if (echo "${INSTALL_VERSION}" | grep -q "beta"); then
            curl -o "${UCRM_PATH}/docker-compose.yml" "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/docker-compose.beta.yml"
        else
            curl -o "${UCRM_PATH}/docker-compose.yml" "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/docker-compose.yml"
        fi

        curl -o "${UCRM_PATH}/docker-compose.migrate.yml" "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/docker-compose.migrate.yml"
        if [[ ! -f "${UCRM_PATH}/docker-compose.env" ]]; then
            curl -o "${UCRM_PATH}/docker-compose.env" "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/docker-compose.env"
        fi

        sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:${INSTALL_VERSION}/g" "${UCRM_PATH}/docker-compose.yml"
        sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:${INSTALL_VERSION}/g" "${UCRM_PATH}/docker-compose.migrate.yml"

        echo "Replacing env in docker compose."
        sed -i -e "s/POSTGRES_PASSWORD=ucrmdbpass1/POSTGRES_PASSWORD=${POSTGRES_PASSWORD}/g" "${UCRM_PATH}/docker-compose.env"
        sed -i -e "s/SECRET=changeThisSecretKey/SECRET=${SECRET}/g" "${UCRM_PATH}/docker-compose.env"
        echo "UCRM_USER=${UCRM_USER}" >> "${UCRM_PATH}/docker-compose.env"

        check_ports
        configure_cloud
        configure_network_subnet
    fi
}

check_port_http() {
    while (nc -z 127.0.0.1 "${PORT_HTTP}" >/dev/null 2>&1); do
        if [ "${INSTALL_CLOUD}" = true ]; then
            echo "ERROR: Port ${PORT_HTTP} is already in use."

            exit 1;
        fi
        read -r -p "Port ${PORT_HTTP} is already in use, please choose a different HTTP port for UCRM. [${ALTERNATIVE_PORT_HTTP}]: " PORT_HTTP
        PORT_HTTP=${PORT_HTTP:-$ALTERNATIVE_PORT_HTTP}
        while ! [[ "${PORT_HTTP}" =~ ^[0-9]+$ ]] || [[ "${PORT_HTTP:-}" -le 0 ]] || [[ "${PORT_HTTP:-}" -ge 65536 ]]; do
            read -r -p "Entered port is invalid, please try again: " PORT_HTTP
        done
    done

    export PORT_HTTP
}

check_port_suspension() {
    while (nc -z 127.0.0.1 "${PORT_SUSPENSION}" >/dev/null 2>&1); do
        if [ "${INSTALL_CLOUD}" = true ]; then
            echo "ERROR: Port ${PORT_SUSPENSION} is already in use."

            exit 1;
        fi
        read -r -p "Port ${PORT_SUSPENSION} is already in use, please choose a different suspension page port for UCRM. [${ALTERNATIVE_PORT_SUSPENSION}]: " PORT_SUSPENSION
        PORT_SUSPENSION=${PORT_SUSPENSION:-$ALTERNATIVE_PORT_SUSPENSION}
        while ! [[ "${PORT_SUSPENSION}" =~ ^[0-9]+$ ]] || [[ "${PORT_SUSPENSION:-}" -le 0 ]] || [[ "${PORT_SUSPENSION:-}" -ge 65536 ]]; do
            read -r -p "Entered port is invalid, please try again: " PORT_SUSPENSION
        done
    done

    export PORT_SUSPENSION
}

check_port_https() {
    while (nc -z 127.0.0.1 "${PORT_HTTPS}" >/dev/null 2>&1); do
        if [ "${INSTALL_CLOUD}" = true ]; then
            echo "ERROR: Port ${PORT_HTTPS} is already in use."

            exit 1;
        fi
        read -r -p "Port ${PORT_HTTPS} is already in use, please choose a different HTTPS port for UCRM. [${ALTERNATIVE_PORT_HTTPS}]: " PORT_HTTPS
        PORT_HTTPS=${PORT_HTTPS:-$ALTERNATIVE_PORT_HTTPS}
        while ! [[ "${PORT_HTTPS}" =~ ^[0-9]+$ ]] || [[ "${PORT_HTTPS:-}" -le 0 ]] || [[ "${PORT_HTTPS:-}" -ge 65536 ]]; do
            read -r -p "Entered port is invalid, please try again: " PORT_HTTPS
        done
    done

    export PORT_HTTPS
}

check_port_netflow() {
    PORT_NETFLOW_ORIGINAL=${PORT_NETFLOW}
    while (nc -z -u -v 127.0.0.1 "${PORT_NETFLOW}" >/dev/null 2>&1); do
        if [ "${INSTALL_CLOUD}" = true ]; then
            echo "ERROR: Port ${PORT_NETFLOW} is already in use."

            exit 1;
        fi
        read -r -p "Port ${PORT_NETFLOW} is already in use, please choose a different NetFlow port for UCRM. [${ALTERNATIVE_PORT_NETFLOW}] (or skip connection test with \"s\"): " PORT_NETFLOW
        PORT_NETFLOW=${PORT_NETFLOW:-$ALTERNATIVE_PORT_NETFLOW}
        while ! [[ "${PORT_NETFLOW}" =~ ^[s|S]{1}$ ]] && (! [[ "${PORT_NETFLOW}" =~ ^[0-9]+$ ]] || [[ "${PORT_NETFLOW:-}" -le 0 ]] || [[ "${PORT_NETFLOW:-}" -ge 65536 ]]); do
            read -r -p "Entered port is invalid, please try again (or skip connection test with \"s\"): " PORT_NETFLOW
        done
        if [[ "${PORT_NETFLOW}" =~ ^(s|S)$ ]]; then
            PORT_NETFLOW=${PORT_NETFLOW_ORIGINAL}

            break
        fi
    done

    export PORT_NETFLOW
}

check_ports() {
    echo "Checking available ports."

    check_port_http
    check_port_suspension
    check_port_https
    check_port_netflow

    sed -i -e "s/- 8080:80/- ${PORT_HTTP}:80/g" "${UCRM_PATH}/docker-compose.yml"
    sed -i -e "s/- 8443:443/- ${PORT_HTTPS}:443/g" "${UCRM_PATH}/docker-compose.yml"
    sed -i -e "s/- 8081:81/- ${PORT_SUSPENSION}:81/g" "${UCRM_PATH}/docker-compose.yml"
    sed -i -e "s/- 2055:2055/- ${PORT_NETFLOW}:2055/g" "${UCRM_PATH}/docker-compose.yml"

    echo "#used only in installation" >> "${UCRM_PATH}/docker-compose.env"
    echo "SERVER_PORT=${PORT_HTTP}" >> "${UCRM_PATH}/docker-compose.env"
    echo "SERVER_SUSPEND_PORT=${PORT_SUSPENSION}" >> "${UCRM_PATH}/docker-compose.env"

    echo "UCRM will be available on port ${PORT_HTTP} (or ${PORT_HTTPS} for HTTPS)."
    echo "UCRM suspension page will be available on port ${PORT_SUSPENSION}."
}

configure_cloud() {
    if [ "$INSTALL_CLOUD" = true ]; then
        if [ -f "${CLOUD_CONF}" ]; then
            cat "${CLOUD_CONF}" >> "${UCRM_PATH}/docker-compose.env"
        fi
    fi
}

patch__compose__add_networks() {
    if ! cat -vt "${UCRM_PATH}/docker-compose.yml" | grep -Eq "networks:";
    then
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
        sed -i -e "s/  migrate_app:/&\n    networks:\n      - internal/g" "${UCRM_PATH}/docker-compose.migrate.yml"
    fi
}

configure_network_subnet() {
    if [[ "${NETWORK_SUBNET}" != "" ]]; then
        patch__compose__add_networks
        sed -i -e "s|    internal: false|&\n    ipam:\n      config:\n        - subnet: ${NETWORK_SUBNET}|g" "${UCRM_PATH}/docker-compose.yml"
    fi

    if [[ "${NETWORK_SUBNET_INTERNAL}" != "" ]]; then
        patch__compose__add_networks
        sed -i -e "s|    internal: true|&\n    ipam:\n      config:\n        - subnet: ${NETWORK_SUBNET_INTERNAL}|g" "${UCRM_PATH}/docker-compose.yml"
    fi
}

download_docker_images() {
    echo "Downloading docker images."
    docker-compose -f "${UCRM_PATH}/docker-compose.yml" pull
}

configure_wizard_user() {
    if ! (is_updating_to_version "${INSTALL_VERSION}" "2006000" 1 1); then
        return 0
    fi

    if ( cat -vt "${UCRM_PATH}/docker-compose.env" | grep -Eq "UCRM_USERNAME" ) && ( cat -vt "${UCRM_PATH}/docker-compose.env" | grep -Eq "UCRM_PASSWORD" );
    then
        UCRM_USERNAME=$(cat -vt "${UCRM_PATH}/docker-compose.env" | grep -E "UCRM_USERNAME=" --color=never | awk -F= ' {print $NF}')
        UCRM_PASSWORD=$(cat -vt "${UCRM_PATH}/docker-compose.env" | grep -E "UCRM_PASSWORD=" --color=never | awk -F= ' {print $NF}')
    elif [[ "${SECURE_FIRST_LOGIN}" = "true" ]]; then
        UCRM_USERNAME="admin"
        UCRM_PASSWORD="$(LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom | fold -w 7 | head -n 1 || true)"

        echo "UCRM_USERNAME=${UCRM_USERNAME}" >> "${UCRM_PATH}/docker-compose.env"
        echo "UCRM_PASSWORD=${UCRM_PASSWORD}" >> "${UCRM_PATH}/docker-compose.env"
    fi
}

print_wizard_login() {
    if [[ "${UCRM_USERNAME}" = "" ]] || [[ "${UCRM_PASSWORD}" = "" ]]; then
        return 0
    fi

    echo ""
    echo "--------------------------------------------------"
    echo "Initial login information:"
    echo "Username: ${UCRM_USERNAME}"
    echo "Password: ${UCRM_PASSWORD}"
    echo "--------------------------------------------------"
    echo ""
}

start_docker_images() {
    echo "Starting docker images."
    docker-compose -f "${UCRM_PATH}/docker-compose.yml" -f "${UCRM_PATH}/docker-compose.migrate.yml" run migrate_app && \
    docker-compose -f "${UCRM_PATH}/docker-compose.yml" up -d && \
    docker-compose -f "${UCRM_PATH}/docker-compose.yml" ps
}

confirm_ucrm_running() {
    local ucrmRunning

    ucrmRunning=false
    n=0
    until [ ${n} -ge 10 ]
    do
        sleep 3s
        ucrmRunning=true
        nc -z 127.0.0.1 "${PORT_HTTP}" && break
        echo "."
        ucrmRunning=false
        n=$((n+1))
    done

    if [[ "${ucrmRunning}" = true ]]; then
        printf "\r%-55s\n" "UCRM ready";

        return 0
    else
        printf "\nUCRM installation failed.\nPlease report this on UCRM Community Forum.\n"

        exit 1
    fi
}

detect_installation_finished() {
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

print_intro() {
    echo "+------------------------------------------------+"
    echo "| UCRM - Complete WISP Management Platform       |"
    echo "|                                                |"
    echo "| https://ucrm.ubnt.com/        (installer v1.8) |"
    echo "+------------------------------------------------+"
    echo ""
}

configure_auto_update_permissions() {
    if [[ ! -d "${UCRM_PATH}/data/ucrm/updates" ]]; then
        mkdir -p "${UCRM_PATH}/data/ucrm/updates"
    fi

    chown -R "${UCRM_USER}" "${UCRM_PATH}"
}

setup_auto_update() {
    if ! (is_updating_to_version "${INSTALL_VERSION}" "2006000" 1 1); then
        return 0
    fi

    if [[ "${NO_AUTO_UPDATE}" = "true" ]]; then
        echo "Skipping auto-update setup."
    else
        if crontab -l -u "${UCRM_USER}"; then
            if ! crontab -u "${UCRM_USER}" -r; then
                echo "Failed to clean crontab."

                exit 1
            fi
        fi

        configure_auto_update_permissions

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

main() {
    print_intro

    if [[ "${SKIP_SYSTEM_SETUP}" = "false" ]]; then
        check_system
        install_docker
        install_docker_compose
        create_user
    fi

    download_docker_compose_files
    download_docker_images
    configure_wizard_user
    setup_auto_update
    start_docker_images
    detect_installation_finished
    print_wizard_login

    exit 0
}

main
