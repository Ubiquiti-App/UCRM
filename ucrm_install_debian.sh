#!/bin/sh

# linux user for ucrm docker containers
UCRM_USER="ucrm"
POSTGRES_PASSWORD=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 48 | head -n 1);
SECRET=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 48 | head -n 1);

DOCKER_CHANGE_8080_PORT=""
DOCKER_CHANGE_8081_PORT=""

which docker > /dev/null 2>&1

if [ $? = 1 ]; then
	echo "Download and install Docker"
	curl -fsSL https://get.docker.com/ | sh
fi

which docker > /dev/null 2>&1

if [ $? = 1 ]; then
	echo "Docker not installed. Please check previous logs. Aborting."
	exit 1
fi

which docker-compose > /dev/null 2>&1

if [ $? = 1 ]; then
	echo "Download and install Docker compose"
	curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
fi

which docker-compose > /dev/null 2>&1

if [ $? = 1 ]; then
	echo "Docker compose not installed. Please check previous logs. Aborting."
	exit 1
fi

if [ -z "$(getent passwd $UCRM_USER)" ]; then
	echo "Creating user $UCRM_USER"
	adduser --disabled-password --gecos "" $UCRM_USER
	usermod -aG docker $UCRM_USER
fi

if [ ! -f /home/$UCRM_USER/docker-compose.yml ]; then
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

	while true; do
		read -r -p "Do you want UCRM to be accessible on port 80? (Yes: recommended for most users, No: will set 8080 as default) [Y/n]: " DOCKER_CHANGE_8080_PORT

		case $DOCKER_CHANGE_8080_PORT in
			[yY][eE][sS]|[yY])
				sed -i -e "s/- 8080:80/- 80:80/g" /home/$UCRM_USER/docker-compose.yml
				echo "U CRM will start at 80 port"
				echo "#used only in instalation" >> /home/$UCRM_USER/docker-compose.env
				echo "SERVER_PORT=80" >> /home/$UCRM_USER/docker-compose.env
				break;;
			[nN][oO]|[nN])
				echo "U CRM will start at 8080 port. If you will change it, edit your docker-compose.yml in $UCRM_USER home direcotry."
				echo "#used only in instalation" >> /home/$UCRM_USER/docker-compose.env
				echo "SERVER_PORT=8080" >> /home/$UCRM_USER/docker-compose.env
				break;;
			*)
				;;
		esac
	done

	while true; do
		read -r -p "Do you want UCRM suspend page to be accessible on port 81? (Yes: recommended for most users, No: will set 8081 as default) [Y/n]: " DOCKER_CHANGE_8081_PORT

		case $DOCKER_CHANGE_8081_PORT in
			[yY][eE][sS]|[yY])
				sed -i -e "s/- 8081:81/- 81:81/g" /home/$UCRM_USER/docker-compose.yml
				echo "U CRM suspend page will start at 81 port"
				echo "#used only in instalation" >> /home/$UCRM_USER/docker-compose.env
				echo "SERVER_SUSPEND_PORT=81" >> /home/$UCRM_USER/docker-compose.env
				break;;
			[nN][oO]|[nN])
				echo "U CRM suspend page will start at 8081 port. If you will change it, edit your docker-compose.yml in $UCRM_USER home direcotry."
				echo "#used only in instalation" >> /home/$UCRM_USER/docker-compose.env
				echo "SERVER_SUSPEND_PORT=8081" >> /home/$UCRM_USER/docker-compose.env
				break;;
			*)
				;;
		esac
	done
fi

echo "Downloading docker images"
cd /home/$UCRM_USER && /usr/local/bin/docker-compose pull

echo "Starting docker images"
cd /home/$UCRM_USER && /usr/local/bin/docker-compose up -d && /usr/local/bin/docker-compose ps

exit 0
