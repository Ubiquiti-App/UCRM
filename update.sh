#!/bin/sh
cat -vt docker-compose.yml | egrep "#  - /home/docker/ucrm/postgres:/var/lib/postgresql/data" > /dev/null

if [ $? = 0 ]; then
    echo "Your docker-compose contains postgres volume inside container. Trying to move outside container."
    echo "Stoping containers"
    docker-compose stop
    docker-compose ps
    DOCKER_POSTGRES_NAME=`docker-compose ps | grep '/docker-entrypoint.sh postgres' | cut -d ' ' -f1`
    echo $DOCKER_POSTGRES_NAME
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

docker-compose pull
docker-compose up -d
