#!/bin/sh

# linux user for ucrm docker containers
UCRM_USER="ucrm"

echo "Download and install Docker"
curl -fsSL https://get.docker.com/ | sh

echo "Download and install Docker compose"
curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

if [ -z "$(getent passwd $UCRM_USER)" ]; then
	echo "Creating user $UCRM_USER"
	adduser --disabled-password --gecos "" $UCRM_USER
	usermod -aG docker $UCRM_USER
fi

echo "Downloading docker compose files"
sudo su $UCRM_USER -c 'curl -o /home/$USER/docker-compose.yml https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.yml'
sudo su $UCRM_USER -c 'curl -o /home/$USER/docker-compose.env https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.env'

echo "Replacing path in docker compose"
sudo su $UCRM_USER -c 'sed -i -e "s/#volumes:/volumes:/g" /home/$USER/docker-compose.yml'
sudo su $UCRM_USER -c 'sed -i -e "s/#  \- \/home\/docker\/ucrm\/postgres:\/var\/lib\/postgresql\/data/  - \/home\/$USER\/postgres:\/var\/lib\/postgresql\/data/g" /home/$USER/docker-compose.yml'
sudo su $UCRM_USER -c 'sed -i -e "s/#  \- \/home\/docker\/ucrm:\/data/  - \/home\/$USER\/data:\/data/g" /home/$USER/docker-compose.yml'

echo "Replacing env in docker compose"
sudo su $UCRM_USER -c 'export POSTGRES_PASSWORD=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 48 | head -n 1); sed -i -e "s/POSTGRES_PASSWORD=ucrmdbpass1/POSTGRES_PASSWORD=$POSTGRES_PASSWORD/g" /home/$USER/docker-compose.env'
sudo su $UCRM_USER -c 'export SECRET=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 48 | head -n 1); sed -i -e "s/SECRET=changeThisSecretKey/SECRET=$SECRET/g" /home/$USER/docker-compose.env'

echo "Downloading docker images"
sudo su $UCRM_USER -c 'cd /home/$USER && /usr/local/bin/docker-compose pull'

echo "Starting docker images"
sudo su $UCRM_USER -c 'cd /home/$USER && /usr/local/bin/docker-compose up -d && /usr/local/bin/docker-compose ps'
