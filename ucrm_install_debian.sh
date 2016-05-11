#!/bin/sh

# linux user for ucrm docker containers
UCRM_USER="ucrm"
POSTGRES_PASSWORD=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 48 | head -n 1);
SECRET=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 48 | head -n 1);

echo "Download and install Docker"
curl -fsSL https://get.docker.com/ | sh

which docker

if [ $? = 1 ]; then
	echo "Docker not installed. Please check previous logs. Aborting."
	exit 1
fi

echo "Download and install Docker compose"
curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

if [ -z "$(getent passwd $UCRM_USER)" ]; then
	echo "Creating user $UCRM_USER"
	adduser --disabled-password --gecos "" $UCRM_USER
	usermod -aG docker $UCRM_USER
fi

echo "Downloading docker compose files"
curl -o /home/$UCRM_USER/docker-compose.yml https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.yml
curl -o /home/$UCRM_USER/docker-compose.env https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.env

echo "Replacing path in docker compose"
sed -i -e "s/#volumes:/volumes:/g" /home/$UCRM_USER/docker-compose.yml
sed -i -e "s/#  \- \/home\/docker\/ucrm\/postgres:\/var\/lib\/postgresql\/data/  - \/home\/$UCRM_USER\/postgres:\/var\/lib\/postgresql\/data/g" /home/$UCRM_USER/docker-compose.yml
sed -i -e "s/#  \- \/home\/docker\/ucrm:\/data/  - \/home\/$UCRM_USER\/data:\/data/g" /home/$UCRM_USER/docker-compose.yml

echo "Replacing env in docker compose"
sed -i -e "s/POSTGRES_PASSWORD=ucrmdbpass1/POSTGRES_PASSWORD=$POSTGRES_PASSWORD/g" /home/$UCRM_USER/docker-compose.env
sed -i -e "s/SECRET=changeThisSecretKey/SECRET=$SECRET/g" /home/$UCRM_USER/docker-compose.env

echo "Downloading docker images"
cd /home/$UCRM_USER && /usr/local/bin/docker-compose pull

echo "Starting docker images"
cd /home/$UCRM_USER && /usr/local/bin/docker-compose up -d && /usr/local/bin/docker-compose ps

exit 0
