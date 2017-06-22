#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace

UCRM_USER="${UCRM_USER:-ucrm}"
UCRM_PATH="${UCRM_PATH:-/home/${UCRM_USER}}"
INSTALL_VERSION="${1:-latest}"

POSTGRES_PASSWORD="$(LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom | fold -w 48 | head -n 1 || true)"
SECRET="$(LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom | fold -w 48 | head -n 1 || true)"
INSTALL_CLOUD="${INSTALL_CLOUD:-false}"

GITHUB_REPOSITORY="U-CRM/billing/master"

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
            echo "Check https://ucrm.ubnt.com/ for minimum system requirements."
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
        echo "Check https://ucrm.ubnt.com/ for minimum system requirements."

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

        change_ucrm_port
        change_ucrm_suspend_port
        enable_ssl
    fi
}

change_ucrm_port() {
    local PORT

    while true; do
        if [ "${INSTALL_CLOUD}" = true ]; then
            PORT=y
        else
            read -r -p "Do you want UCRM to be accessible on port 80? (Yes: recommended for most users, No: will set 8080 as default) [Y/n]: " PORT
        fi

        case "${PORT}" in
            [yY][eE][sS]|[yY])
                sed -i -e "s/- 8080:80/- 80:80/g" "${UCRM_PATH}/docker-compose.yml"
                sed -i -e "s/- 8443:443/- 443:443/g" "${UCRM_PATH}/docker-compose.yml"
                echo "UCRM will start at 80 port."
                echo "#used only in instalation" >> "${UCRM_PATH}/docker-compose.env"
                echo "SERVER_PORT=80" >> "${UCRM_PATH}/docker-compose.env"
                break;;
            [nN][oO]|[nN])
                echo "UCRM will start at 8080 port. If you will change it, edit your docker-compose.yml in ${UCRM_USER} home directory."
                echo "#used only in instalation" >> "${UCRM_PATH}/docker-compose.env"
                echo "SERVER_PORT=8080" >> "${UCRM_PATH}/docker-compose.env"
                break;;
            *)
                ;;
        esac
    done
}

change_ucrm_suspend_port() {
    local PORT

    while true; do
        if [ "${INSTALL_CLOUD}" = true ]; then
            PORT=y
        else
            read -r -p "Do you want UCRM suspend page to be accessible on port 81? (Yes: recommended for most users, No: will set 8081 as default) [Y/n]: " PORT
        fi

        case "${PORT}" in
            [yY]*)
                sed -i -e "s/- 8081:81/- 81:81/g" "${UCRM_PATH}/docker-compose.yml"
                echo "UCRM suspend page will start at 81 port."
                echo "#used only in installation" >> "${UCRM_PATH}/docker-compose.env"
                echo "SERVER_SUSPEND_PORT=81" >> "${UCRM_PATH}/docker-compose.env"
                break;;
            [nN]*)
                echo "UCRM suspend page will start at 8081 port. If you will change it, edit your docker-compose.yml in ${UCRM_USER} home directory."
                echo "#used only in installation" >> "${UCRM_PATH}/docker-compose.env"
                echo "SERVER_SUSPEND_PORT=8081" >> "${UCRM_PATH}/docker-compose.env"
                break;;
            *)
                ;;
        esac
    done
}

enable_ssl() {
    local SSL

    while true; do
        if [ "${INSTALL_CLOUD}" = true ]; then
            SSL=y
        else
            read -r -p "Do you want to enable SSL? (You need to generate a certificate for yourself) [Y/n]: " SSL
        fi

        case "${SSL}" in
            [yY]*)
                enable_server_name
                change_ucrm_ssl_port
                break;;
            [nN]*)
                echo "UCRM has disabled support for SSL."
                break;;
            *)
                ;;
        esac
    done
}

enable_server_name() {
    local SERVER_NAME_LOCAL

    if [ "$INSTALL_CLOUD" = true ]; then
        if [ -f "${CLOUD_CONF}" ]; then
            cat "${CLOUD_CONF}" >> "${UCRM_PATH}/docker-compose.env"
        fi
    else
        read -r -p "Enter Server domain name for UCRM, for example ucrm.example.com: " SERVER_NAME_LOCAL
        echo "SERVER_NAME=${SERVER_NAME_LOCAL}" >> "${UCRM_PATH}/docker-compose.env"
    fi
}

change_ucrm_ssl_port() {
    local PORT

    while true; do
        if [ "${INSTALL_CLOUD}" = true ]; then
            PORT=y
        else
            read -r -p "Do you want UCRM SSL to be accessible on port 443? (Yes: recommended for most users, No: will set 8443 as default) [Y/n]: " PORT
        fi

        case "${PORT}" in
            [yY]*)
                sed -i -e "s/- 8443:443/- 443:443/g" "${UCRM_PATH}/docker-compose.yml"
                echo "UCRM SSL will start at 443 port."
                break;;
            [nN]*)
                echo "UCRM SSL will start at 8443 port."
                break;;
            *)
                ;;
        esac
    done
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
    	fi' || printf "\nUCRM installation failed.\nPlease report this on UCRM Community Forum.\n"
}

main() {
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
