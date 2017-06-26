#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace

UCRM_USER="${UCRM_USER:-ucrm}"
UCRM_PATH="${UCRM_PATH:-/home/${UCRM_USER}}"
INSTALL_VERSION="latest"

POSTGRES_PASSWORD="$(LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom | fold -w 48 | head -n 1 || true)"
SECRET="$(LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom | fold -w 48 | head -n 1 || true)"
INSTALL_CLOUD="${INSTALL_CLOUD:-false}"

GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-U-CRM/billing/master}"

NETWORK_SUBNET="${NETWORK_SUBNET:-}"
NETWORK_SUBNET_INTERNAL="${NETWORK_SUBNET_INTERNAL:-}"
PORT_HTTP="${PORT_HTTP:-80}"
PORT_SUSPENSION="${PORT_SUSPENSION:-81}"
PORT_HTTPS="${PORT_HTTPS:-443}"
ALTERNATIVE_PORT_HTTP="${ALTERNATIVE_PORT_HTTP:-8080}"
ALTERNATIVE_PORT_SUSPENSION="${ALTERNATIVE_PORT_SUSPENSION:-8081}"
ALTERNATIVE_PORT_HTTPS="${ALTERNATIVE_PORT_HTTPS:-8443}"

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
  *)
    # unknown option
    ;;
esac
shift # past argument key
done

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

    local DOCKER_COMPOSE_VERSION="$(docker-compose -v | sed 's/.*version \([0-9]*\.[0-9]*\).*/\1/')"
    local DOCKER_COMPOSE_MAJOR="${DOCKER_COMPOSE_VERSION%.*}"
    local DOCKER_COMPOSE_MINOR="${DOCKER_COMPOSE_VERSION#*.}"

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
        curl -o "${UCRM_PATH}/docker-compose.env" "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/docker-compose.env"

        sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:${INSTALL_VERSION}/g" "${UCRM_PATH}/docker-compose.yml"
        sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:${INSTALL_VERSION}/g" "${UCRM_PATH}/docker-compose.migrate.yml"

        echo "Replacing env in docker compose."
        sed -i -e "s/POSTGRES_PASSWORD=ucrmdbpass1/POSTGRES_PASSWORD=${POSTGRES_PASSWORD}/g" "${UCRM_PATH}/docker-compose.env"
        sed -i -e "s/SECRET=changeThisSecretKey/SECRET=${SECRET}/g" "${UCRM_PATH}/docker-compose.env"

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

check_ports() {
    echo "Checking available ports."

    check_port_http
    check_port_suspension
    check_port_https

    sed -i -e "s/- 8080:80/- ${PORT_HTTP}:80/g" "${UCRM_PATH}/docker-compose.yml"
    sed -i -e "s/- 8443:443/- ${PORT_HTTPS}:443/g" "${UCRM_PATH}/docker-compose.yml"
    sed -i -e "s/- 8081:81/- ${PORT_SUSPENSION}:81/g" "${UCRM_PATH}/docker-compose.yml"

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

configure_network_subnet() {
    if [[ "${NETWORK_SUBNET}" != "" ]]; then
        sed -i -e "s|    internal: false|&\n    ipam:\n      config:\n        - subnet: ${NETWORK_SUBNET}|g" "${UCRM_PATH}/docker-compose.yml"
    fi

    if [[ "${NETWORK_SUBNET_INTERNAL}" != "" ]]; then
        sed -i -e "s|    internal: true|&\n    ipam:\n      config:\n        - subnet: ${NETWORK_SUBNET_INTERNAL}|g" "${UCRM_PATH}/docker-compose.yml"
    fi
}

download_docker_images() {
    echo "Downloading docker images."
    cd "${UCRM_PATH}" && /usr/local/bin/docker-compose pull
}

start_docker_images() {
    echo "Starting docker images."
    cd "${UCRM_PATH}" && \
    /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.migrate.yml run migrate_app && \
    /usr/local/bin/docker-compose up -d && \
    /usr/local/bin/docker-compose ps
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
    containerName=$(/usr/local/bin/docker-compose ps | grep -m1 "make server" | awk '{print $1}')
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
    echo "| https://ucrm.ubnt.com/        (installer v1.0) |"
    echo "+------------------------------------------------+"
    echo ""
}

main() {
    print_intro
    check_system
    install_docker
    install_docker_compose
    create_user
    download_docker_compose_files
    download_docker_images
    start_docker_images
    detect_installation_finished

    exit 0
}

main
