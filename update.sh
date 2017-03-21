#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace

DATE=$(date +"%s")
MIGRATE_OUTPUT=$(mktemp)
FORCE_UPDATE=0
PATCH_STABILITY="latest"
GITHUB_REPOSITORY="U-CRM/billing/master"

trap 'rm -f "${MIGRATE_OUTPUT}"; exit' INT TERM EXIT

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
    if [[ ! -d ./docker-compose-backups ]]; then
        mkdir ./docker-compose-backups
    fi

    if [[ "" != "$(find . -maxdepth 1 -name 'docker-compose.env.*.backup' -print -quit)" ]]; then
        mv -f docker-compose.env.*.backup ./docker-compose-backups
    fi

    if [[ "" != "$(find . -maxdepth 1 -name 'docker-compose.yml.*.backup' -print -quit)" ]]; then
        mv -f docker-compose.yml.*.backup ./docker-compose-backups
    fi

    cp docker-compose.yml ./docker-compose-backups/docker-compose.yml."${DATE}".backup
    cp docker-compose.env ./docker-compose-backups/docker-compose.env."${DATE}".backup
}

compose__restore() {
    echo "Reverting docker compose files."
    cp -f ./docker-compose-backups/docker-compose.yml."${DATE}".backup docker-compose.yml
    cp -f ./docker-compose-backups/docker-compose.env."${DATE}".backup docker-compose.env
}

patch__compose__add_elastic_section() {
    if ! ( cat -vt docker-compose.yml | grep -Eq "  elastic:" );
    then
        echo "Your docker-compose doesn't contain Elastic section. Trying to add."
        echo -e "\n\n  elastic:\n    image: elasticsearch:2\n    restart: always" >> docker-compose.yml
    fi
}

patch__compose__add_elastic_links() {
    if ( cat -vt docker-compose.yml | tr -d '\n' | grep -Eq "      - postgresql {4}[a-z]" );
    then
        echo "Adding Elastic container links."
        sed -i -e "/      - elastic/d" docker-compose.yml
        sed -i -e "s/      - postgresql/&\n      - elastic/g" docker-compose.yml
    fi
}

patch__compose__fix_postgres_restart() {
    if ! ( grep 'image: postgres' -A1 docker-compose.yml | grep -q "restart" );
    then
        echo "Updating postgres service"
        sed -i -e "s/image: postgres:9.5/&\n    restart: always/g" docker-compose.yml
    fi
}

patch__compose__fix_elastic_restart() {
    if ! ( grep 'image: elasticsearch' -A1 docker-compose.yml | grep -q "restart" );
    then
        echo "Updating elastic service"
        sed -i -e "s/image: elasticsearch:2/&\n    restart: always/g" docker-compose.yml
    fi
}

patch__compose__add_logging() {
    if ! cat -vt docker-compose.yml | grep -Eq "    logging:";
    then
        echo "Updating logging configuration."
        sed -i -e "s/^  [a-z_]\+:$/&\n    logging:\n      driver: \"json-file\"\n      options:\n        max-size: \"10m\"\n        max-file: \"3\"/g" docker-compose.yml
    fi
}

patch__compose__download_migrate_file() {
    if [[ ! -f docker-compose.migrate.yml ]]; then
        echo "Downloading docker compose migrate file."
        curl -o docker-compose.migrate.yml "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/docker-compose.migrate.yml"
        check_yml docker-compose.migrate.yml docker-compose.yml

        return 0
    else
        check_yml docker-compose.migrate.yml docker-compose.yml

        return 1
    fi
}

patch__compose__add_search_devices_section() {
    if ! ( cat -vt docker-compose.yml | grep -Eq "  crm_search_devices_app:" );
    then
        echo "Your docker-compose doesn't contain UCRM search devices section. Trying to add."
        echo -e "\n  crm_search_devices_app:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n    command: \"crm_search_devices\"" >> docker-compose.yml

        return 0
    else
        return 1
    fi
}

patch__compose__add_netflow_section() {
    if ! (cat -vt docker-compose.yml | grep -Eq "  crm_netflow_app:");
    then
        echo "Your docker-compose doesn't contain Netflow section. Trying to add."
        echo -e "\n  crm_netflow_app:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n    ports:\n      - 2055:2055/udp\n    command: \"crm_netflow\"" >> docker-compose.yml

        return 0
    else
        return 1
    fi
}

patch__compose__add_ping_section() {
    if ! cat -vt docker-compose.yml | grep -Eq "  crm_ping_app:";
    then
        echo "Your docker-compose doesn't contain Ping section. Trying to add."
        echo -e "\n  crm_ping_app:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n    command: \"crm_ping\"" >> docker-compose.yml

        return 0
    else
        return 1
    fi
}

patch__compose__add_elasticsearch_volumes() {
    if ! cat -vt docker-compose.yml | grep -Eq "/usr/share/elasticsearch/data";
    then
        echo "Updating Elasticsearch volumes configuration."
        sed -i -e "s/image: elasticsearch:2/&\n    volumes:\n      - \.\/data\/elasticsearch:\/usr\/share\/elasticsearch\/data/g" docker-compose.yml

        return 0
    else
        return 1
    fi
}

patch__compose__add_rabbitmq() {
    if ! cat -vt docker-compose.yml | grep -Eq "  rabbitmq:";
    then
        echo "Your docker-compose doesn't contain RabbitMQ and supervisord sections. Trying to add."
        echo -e "\n  rabbitmq:\n    image: rabbitmq:3\n    restart: always\n    volumes:\n      - ./data/rabbitmq:/var/lib/rabbitmq\n\n  supervisord:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n      - elastic\n    command: \"supervisord\"" >> docker-compose.yml
        echo "Adding RabbitMQ container links."
        sed -i -e "s/      - elastic/&\n      - rabbitmq/g" docker-compose.yml

        return 0
    else
        return 1
    fi
}

patch__compose__remove_draft_approve() {
    if [[ "${PATCH_STABILITY}" != "beta" ]]; then
        return 1
    fi

    if cat -vt docker-compose.yml | grep -Eq "  crm_draft_approve_app:";
    then
        echo "Your docker-compose contains obsolete section crm_draft_approve_app. Trying to remove."
        sed -i -e '/crm_draft_approve_app/,/^  [^ ]/{//!d}' docker-compose.yml
        sed -i -e '/crm_draft_approve_app/d' docker-compose.yml

        return 0
    else
        return 1
    fi
}

patch__compose__remove_invoice_send_email() {
    if [[ "${PATCH_STABILITY}" != "beta" ]]; then
        return 1
    fi

    if cat -vt docker-compose.yml | grep -Eq "  crm_invoice_send_email_app:";
    then
        echo "Your docker-compose contains obsolete section crm_invoice_send_email_app. Trying to remove."
        sed -i -e '/crm_invoice_send_email_app/,/^  [^ ]/{//!d}' docker-compose.yml
        sed -i -e '/crm_invoice_send_email_app/d' docker-compose.yml

        return 0
    else
        return 1
    fi
}

patch__compose__correct_volumes() {
    declare newPath="${1}"

    echo "Correcting volumes path."
    sed -i -e "s/      - .\/data\/ucrm:\/data/${newPath}/g" docker-compose.yml
    sed -i -e "s/      - .\/data\/ucrm:\/data/${newPath}/g" docker-compose.migrate.yml
}

patch__compose_env__fix_server_port() {
    if ! grep -q 'SERVER_PORT' docker-compose.env;
    then
        SERVER_PORT=$(grep -A 20 --color=never "web_app" docker-compose.yml | grep -B 20 --color=never 'command: "server"' | awk '/\-\ ([0-9]+)\:80/{print $2}' | cut -d ':' -f1)
        echo "Adding ${SERVER_PORT} as server port, you can change it in UCRM System > Settings > Application > Server port"
        echo "#used only in installation" >> docker-compose.env
        echo "SERVER_PORT=${SERVER_PORT}" >> docker-compose.env
    fi
}

patch__compose_env__fix_suspend_port() {
    if ! grep -q 'SERVER_SUSPEND_PORT' docker-compose.env;
    then
        SERVER_SUSPEND_PORT=$(grep -A 20 --color=never "web_app" docker-compose.yml | grep -B 20 --color=never 'command: "server"' | awk '/\-\ ([0-9]+)\:81/{print $2}' | cut -d ':' -f1)
        echo "Adding ${SERVER_SUSPEND_PORT} as suspend port, you can change it in UCRM System > Settings > Application > Server suspend port"
        echo "#used only in installation" >> docker-compose.env
        echo "SERVER_SUSPEND_PORT=${SERVER_SUSPEND_PORT}" >> docker-compose.env
    fi
}

patch__compose_env__fix_server_name() {
    if ! grep -q 'SERVER_NAME' docker-compose.env;
    then
        echo "Adding ucrm.ubnt as Server domain name, you can change it in UCRM System > Settings > Application > Server domain name"
        echo "#used only in installation" >> docker-compose.env
        echo "SERVER_NAME=ucrm.ubnt" >> docker-compose.env

        if ! grep -q "443:443" docker-compose.yml;
        then
            if grep -q "\- 8080:80" docker-compose.yml;
            then
                echo "Adding 8443 as SSL port"
                sed -i -e "s/:81/&\n      - 8443:443/g" docker-compose.yml
            else
                echo "Adding 443 as SSL port"
                sed -i -e "s/:81/&\n      - 443:443/g" docker-compose.yml
            fi
        fi
    fi
}

compose__get_correct_volumes_path() {
    if ! ( cat -vt docker-compose.yml | grep -Eq "\.\/data\/ucrm:\/data" );
    then
        cat -vt docker-compose.yml | grep -E "^      \- \/home\/.+:\/data$" -m 1 --color=never | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g'
    else
        echo ""
    fi
}

compose__run_update() {
    declare toVersion="${1}"
    local needsVolumesFix
    local volumesPath

    if (echo "${toVersion}" | grep -q "beta"); then
        PATCH_STABILITY="beta"
    fi

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

    patch__compose__remove_draft_approve
    patch__compose__remove_invoice_send_email

    if [[ "${needsVolumesFix}" = "1" ]] && [[ "${volumesPath}" != "" ]]; then
        patch__compose__correct_volumes "${volumesPath}"
    fi

    patch__compose_env__fix_server_port
    patch__compose_env__fix_suspend_port
    patch__compose_env__fix_server_name

    check_yml docker-compose.yml
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

    sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:${version}/g" docker-compose.yml
    sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:${version}/g" docker-compose.migrate.yml

    if ! (docker-compose pull); then
        if [[ "${FORCE_UPDATE}" = "0" ]]; then
            echo "Image for version \"${version}\" not found."
            compose__restore

            exit 1
        fi
    fi
    docker-compose -f docker-compose.yml -f docker-compose.migrate.yml stop
    docker-compose -f docker-compose.yml -f docker-compose.migrate.yml rm -af

    if containers__is_revert_supported "${version}";
    then
        if ( docker-compose -f docker-compose.yml -f docker-compose.migrate.yml run migrate_app | tee "${MIGRATE_OUTPUT}" );
        then
            docker-compose -f docker-compose.yml -f docker-compose.migrate.yml rm -af
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

                docker-compose -f docker-compose.yml -f docker-compose.migrate.yml stop
                docker-compose -f docker-compose.yml -f docker-compose.migrate.yml rm -af

                exit 1
            fi

            return
        fi

    fi

    docker-compose up -d
    docker-compose ps
}

get_from_version() {
    local fromVersion

    if [[ ! -f docker-compose.version.yml ]]; then
        curl -o docker-compose.version.yml "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/docker-compose.version.yml"
    fi

    check_yml docker-compose.version.yml

    currentComposeImage="$(grep -Eo --color=never "ucrm-billing:.+" docker-compose.yml | head -1 | awk -F: '{print $NF}')"
    sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:${currentComposeImage}/g" docker-compose.version.yml

    fromVersion=$(docker-compose -f docker-compose.version.yml run get_version_app | tr -d '\n' | grep -Eo --color=never "version:.+" | awk -F: '{print $NF}' | tr -d '[:space:]')
    docker-compose -f docker-compose.version.yml rm -af > /dev/null 2>&1

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

    oldImages=$(docker images | grep --color=never "ubnt/ucrm-billing" | grep --color=never "<none>" | awk '{print $3}') || true
    if [[ "${oldImages:-}" != "" ]]; then
        echo "Removing old UCRM images"
        docker rmi "${oldImages}"
    fi

    if (docker system --help > /dev/null 2>&1);
    then
        echo -e "\n----------------\n"
        echo "We recommend running \"docker system prune\" once in a while to clean unused containers, images, etc."
        echo "You can determine how much space can be cleaned up by running \"docker system df\""
    fi
}

cleanup_old_backups() {
    (find . -maxdepth 1 -name 'docker-compose.env.*.backup' -type f -printf "%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
    (find . -maxdepth 1 -name 'docker-compose.yml.*.backup' -type f -printf "%f\n" | sort | tail -n +61 | xargs -I {} rm -- {})
}

flush_udp_conntrack() {
    docker run --net=host --privileged --rm ubnt/ucrm-conntrack
}

do_update() {
    declare toVersion="${1}"

    compose__backup
    compose__run_update "${toVersion}"
    containers__run_update "${toVersion}"
    flush_udp_conntrack

    cleanup_old_images
    cleanup_old_backups
}

main() {
    declare toVersion="${1}"
    local fromVersion

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

while getopts ":f" opt; do
  case "${opt}" in
    f)
      FORCE_UPDATE=1
      ;;
  esac
done

if [[ "${FORCE_UPDATE}" = "1" ]]; then
    do_update "${2:-}"
else
    main "${1:-}"
fi
