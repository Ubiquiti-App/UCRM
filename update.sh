#!/bin/bash

DATE=$(date +"%s")

cp docker-compose.yml docker-compose.yml.$DATE.backup
cp docker-compose.env docker-compose.env.$DATE.backup

cat -vt docker-compose.yml | egrep "  elastic:" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain Elastic section. Trying to add."
	echo -e "\n\n  elastic:\n    image: elasticsearch:2\n    restart: always" >> docker-compose.yml
fi

cat -vt docker-compose.yml | egrep "  crm_search_devices_app:" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain UCRM search devices section. Trying to add."
	echo -e "\n\n  crm_search_devices_app:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    #volumes:\n    #  - ./data/ucrm:/data\n    links:\n      - postgresql\n    command: \"crm_search_devices\"" >> docker-compose.yml
fi

cat -vt docker-compose.yml | egrep "      - elastic" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain Elastic link in the Web App container. Trying to add."
	sed -i -e "s/      - postgresql/&\n      - elastic/g" docker-compose.yml
fi

cat -vt docker-compose.yml | egrep "  influxdb:" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain Influxdb section. Trying to add."
	echo -e "\n  influxdb:\n    image: influxdb:0.13-alpine\n    restart: always\n    volumes:\n      - ./data/influxdb:/var/lib/influxdb" >> docker-compose.yml
fi

cat -vt docker-compose.yml | egrep "  crm_netflow:" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain Netflow section. Trying to add."
	echo -e "\n  crm_netflow:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n      - influxdb\n    ports:\n      - 2055:2055\n    command: \"crm_netflow\"" >> docker-compose.yml
fi

cat -vt docker-compose.yml | egrep "  crm_ping:" > /dev/null

if [ $? = 1 ]; then
	echo "Your docker-compose doesn't contain Ping section. Trying to add."
	echo -e "\n  crm_ping:\n    image: ubnt/ucrm-billing:latest\n    restart: always\n    env_file: docker-compose.env\n    volumes:\n      - ./data/ucrm:/data\n    links:\n      - postgresql\n      - influxdb\n    command: \"crm_ping\"" >> docker-compose.yml
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

docker-compose pull
docker-compose stop
docker-compose up -d
