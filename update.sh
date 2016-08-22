#!/bin/bash

DATE=$(date +"%s")

cp docker-compose.yml docker-compose.yml.$DATE.backup
cp docker-compose.env docker-compose.env.$DATE.backup

cat -vt docker-compose.yml | egrep "#  - /home/docker/ucrm/postgres:/var/lib/postgresql/data" > /dev/null

if [ $? = 0 ]; then
	echo "Your docker-compose contains postgres volume inside the container. Trying to move it outside."
	echo "Stopping containers"
	docker-compose stop
	docker-compose ps
	DOCKER_POSTGRES_NAME=`docker-compose ps | grep '/docker-entrypoint.sh postgres' | cut -d ' ' -f1`

	if [ -z $DOCKER_POSTGRES_NAME ]; then
		read -p "Enter postgres container name: " DOCKER_POSTGRES_NAME
	fi

	echo "Using container $DOCKER_POSTGRES_NAME"
	echo "Starting PostgreSQL container"
	docker start $DOCKER_POSTGRES_NAME
	sleep 5
	docker exec $DOCKER_POSTGRES_NAME bash -c 'mkdir data && chown postgres:postgres /data && gosu postgres pg_dump $POSTGRES_DB --column-inserts --disable-dollar-quoting --disable-triggers --format=custom -f /data/_ucrm_dump.custom.backup'
	docker commit -p $DOCKER_POSTGRES_NAME ucrm-postgres-with-data
	docker images | grep ucrm-postgres-with-data
	docker run -v $PWD/data/postgres/backup:/data_host ucrm-postgres-with-data bash -c 'cp /data/_ucrm_dump.custom.backup /data_host/_ucrm_dump.custom.backup'

	sed -i -e "s/#volumes:/volumes:/g" docker-compose.yml
	sed -i -e "s/#  - \/home\/docker\/ucrm\/postgres:\/var\/lib\/postgresql\/data/  - .\/data\/postgres:\/data\\n    environment:\\n      - PGDATA=\/data\/pg/g" docker-compose.yml
	sed -i -e "s/#  - \/home\/docker\/ucrm:\/data/  - .\/data\/ucrm:\/data/g" docker-compose.yml

	docker-compose stop
	docker-compose rm --all
	docker-compose up -d --no-deps postgresql
	sleep 5
	docker exec $DOCKER_POSTGRES_NAME bash -c 'pg_restore -d $POSTGRES_DB -U $POSTGRES_USER -j 4 /data/backup/_ucrm_dump.custom.backup'

fi

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
