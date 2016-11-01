#!/bin/bash

DATE=$(date +"%s")

cp docker-compose.yml docker-compose.yml.$DATE.backup
cp docker-compose.env docker-compose.env.$DATE.backup

cat -vt docker-compose.yml | egrep "  elastic:" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain Elastic section. Trying to add."
	echo -e "\n\n  elastic:\n    image: elasticsearch:2\n    restart: always" >> docker-compose.yml
fi

cat -vt docker-compose.yml | egrep "      - elastic" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain Elastic link in the Web App container. Trying to add."
	sed -i -e "s/      - postgresql/&\n      - elastic/g" docker-compose.yml
fi

cat docker-compose.yml | grep 'image: postgres' -A1 | grep restart > /dev/null

if [ $? = 1 ]; then
	echo "Updating postgres service"
	sed -i -e "s/image: postgres:9.5/&\n    restart: always/g" docker-compose.yml
fi

cat docker-compose.yml | grep 'image: elasticsearch' -A1 | grep restart > /dev/null

if [ $? = 1 ]; then
	echo "Updating elastic service"
	sed -i -e "s/image: elasticsearch:2/&\n    restart: always/g" docker-compose.yml
fi

cat -vt docker-compose.yml | egrep "\.\/data\/ucrm:\/data" > /dev/null
if [ $? = 1 ]; then
	VOLUME=$(cat -vt docker-compose.yml | egrep "^      \- \/home\/.+:\/data$" -m 1 --color="never" | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
else
	VOLUME=""
fi

NEEDS_VOLUMES_FIX=0

if [ ! -f docker-compose.migrate.yml ]; then
    echo "Downloading docker compose migrate file."
    curl -o /home/$UCRM_USER/docker-compose.migrate.yml https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.migrate.yml
    NEEDS_VOLUMES_FIX=1
fi

cat -vt docker-compose.yml | egrep "  crm_search_devices_app:" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain UCRM search devices section. Trying to add."
	echo -e "\n  crm_search_devices_app:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n    command: \"crm_search_devices\"" >> docker-compose.yml
	NEEDS_VOLUMES_FIX=1
fi

cat -vt docker-compose.yml | egrep "  crm_netflow_app:" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain Netflow section. Trying to add."
	echo -e "\n  crm_netflow_app:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n    ports:\n      - 2055:2055/udp\n    command: \"crm_netflow\"" >> docker-compose.yml
	NEEDS_VOLUMES_FIX=1
fi

cat -vt docker-compose.yml | egrep "  crm_ping_app:" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain Ping section. Trying to add."
	echo -e "\n  crm_ping_app:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n    command: \"crm_ping\"" >> docker-compose.yml
	NEEDS_VOLUMES_FIX=1
fi

if [ "$NEEDS_VOLUMES_FIX" = "1" ] && [ "$VOLUME" != "" ]; then
	echo "Correcting volumes path."
	sed -i -e "s/      - .\/data\/ucrm:\/data/$VOLUME/g" docker-compose.yml
	sed -i -e "s/      - .\/data\/ucrm:\/data/$VOLUME/g" docker-compose.migrate.yml
fi

grep 'SERVER_PORT' docker-compose.env > /dev/null

if [ $? = 1 ]; then
	SERVER_PORT=`grep -A 20 "web_app" docker-compose.yml | grep -B 20 'command: "server"' | awk '/\-\ ([0-9]+)\:80/{print $2}' | cut -d ':' -f1`
	echo "Adding $SERVER_PORT as server port, you can change it in UCRM Settings > General > System > Application > Server port"
	echo "#used only in instalation" >> docker-compose.env
	echo "SERVER_PORT=$SERVER_PORT" >> docker-compose.env
fi

grep 'SERVER_SUSPEND_PORT' docker-compose.env > /dev/null

if [ $? = 1 ]; then
	SERVER_SUSPEND_PORT=`grep -A 20 "web_app" docker-compose.yml | grep -B 20 'command: "server"' | awk '/\-\ ([0-9]+)\:81/{print $2}' | cut -d ':' -f1`
	echo "Adding $SERVER_SUSPEND_PORT as suspend port, you can change it in UCRM Settings > General > System > Application > Server suspend port"
	echo "#used only in instalation" >> docker-compose.env
	echo "SERVER_SUSPEND_PORT=$SERVER_SUSPEND_PORT" >> docker-compose.env
fi

grep 'SERVER_NAME' docker-compose.env > /dev/null

if [ $? = 1 ]; then
	echo "Adding ucrm.ubnt as Server domain name, you can change it in UCRM Settings > General > System > Application > Server domain name"
	echo "#used only in instalation" >> docker-compose.env
	echo "SERVER_NAME=ucrm.ubnt" >> docker-compose.env

	grep "443:443" docker-compose.yml > /dev/null
	if [ $? = 1 ]; then
		grep "\- 8080:80" docker-compose.yml
		if [ $? = 0 ]; then
			echo "Adding 8443 as SSL port"
			sed -i -e "s/:81/&\n      - 8443:443/g" docker-compose.yml
		else
			echo "Adding 443 as SSL port"
			sed -i -e "s/:81/&\n      - 443:443/g" docker-compose.yml
		fi
	fi
fi

MIGRATE_OUTPUT=`mktemp`

isRevertSupported() {
    if [ $1 = latest ]; then
        echo 't'
    elif [ $(echo $1 | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }') -ge 2001005 ]; then
        echo 't'
    else
        echo 'f'
    fi
}

revert() {
    echo "Reverting docker compose files."
    cp -f docker-compose.yml.$DATE.backup docker-compose.yml
    cp -f docker-compose.env.$DATE.backup docker-compose.env

    echo "Reverting UCRM to version $1"
    update $1

    echo "Revert complete."
}

update() {
    sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:$1/g" docker-compose.yml
    sed -i -e "s/    image: ubnt\/ucrm-billing:.*/    image: ubnt\/ucrm-billing:$1/g" docker-compose.migrate.yml

    docker-compose pull
    docker-compose stop
    docker-compose rm -af

    if [ $(isRevertSupported $1) = 't' ]; then

        docker-compose -f docker-compose.yml -f docker-compose.migrate.yml run migrate_app | tee $MIGRATE_OUTPUT ; ( exit ${PIPESTATUS[0]} )
        if [ $? != 0 ]; then
            REVERT_VERSION=$(grep 'UCRM will be reverted to version' $MIGRATE_OUTPUT | awk ' {print $NF}')
            if [ $REVERT_VERSION ]; then
                revert $REVERT_VERSION
                return
            fi
        fi

    fi

    docker-compose up -d
    docker-compose ps
}

update latest
rm -f $MIGRATE_OUTPUT

exit 0
