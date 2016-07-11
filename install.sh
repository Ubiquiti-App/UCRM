#!/bin/bash

# linux user for ucrm docker containers
UCRM_USER="ucrm"
POSTGRES_PASSWORD=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 48 | head -n 1);
SECRET=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 48 | head -n 1);

check_system() {
	local lsb_dist
	local dist_version

	if [ -z "$lsb_dist" ] && [ -r /etc/lsb-release ]; then
		lsb_dist="$(. /etc/lsb-release && echo "$DISTRIB_ID")"
	fi

	if [ -z "$lsb_dist" ] && [ -r /etc/debian_version ]; then
		lsb_dist='debian'
	fi

	if [ -z "$lsb_dist" ] && [ -r /etc/fedora-release ]; then
		lsb_dist='fedora'
	fi

	if [ -z "$lsb_dist" ] && [ -r /etc/oracle-release ]; then
		lsb_dist='oracleserver'
	fi

	if [ -z "$lsb_dist" ]; then
		if [ -r /etc/centos-release ] || [ -r /etc/redhat-release ]; then
		lsb_dist='centos'
		fi
	fi

	if [ -z "$lsb_dist" ] && [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi

	lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

	case "$lsb_dist" in

		ubuntu)
		if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
			dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
		fi
		;;

		debian)
		dist_version="$(cat /etc/debian_version | sed 's/\/.*//' | sed 's/\..*//')"
		;;

		*)
		if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
			dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
		fi
		;;

	esac

	if [ "$lsb_dist" = "ubuntu" ] && [ "$dist_version" != "xenial" ] || [ "$lsb_dist" = "debian" ] && [ "$dist_version" != "8" ]; then
		echo "Unsupported distro."
		echo "Supported was: Ubuntu Xenial and Debian 8."
		echo $lsb_dist
		echo $dist_version
		exit 1
	fi
}

install_docker() {
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
}

install_docker_compose() {
	which docker-compose > /dev/null 2>&1

	if [ $? = 1 ]; then
		echo "Download and install Docker compose."
		curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
		chmod +x /usr/local/bin/docker-compose
	fi

	which docker-compose > /dev/null 2>&1

	if [ $? = 1 ]; then
		echo "Docker compose not installed. Please check previous logs. Aborting."
		exit 1
	fi
}

create_user() {
	if [ -z "$(getent passwd $UCRM_USER)" ]; then
		echo "Creating user $UCRM_USER."
		adduser --disabled-password --gecos "" $UCRM_USER
		usermod -aG docker $UCRM_USER
	fi
}

download_docker_compose_files() {
	if [ ! -f /home/$UCRM_USER/docker-compose.yml ]; then
		echo "Downloading docker compose files."
		curl -o /home/$UCRM_USER/docker-compose.yml https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.yml
		curl -o /home/$UCRM_USER/docker-compose.env https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.env

		echo "Replacing path in docker compose."
		sed -i -e "s/#volumes:/volumes:/g" /home/$UCRM_USER/docker-compose.yml
		sed -i -e "s/#  \- \/home\/docker\/ucrm\/postgres:\/var\/lib\/postgresql\/data/  - \/home\/$UCRM_USER\/postgres:\/var\/lib\/postgresql\/data/g" /home/$UCRM_USER/docker-compose.yml
		sed -i -e "s/#  \- \/home\/docker\/ucrm:\/data/  - \/home\/$UCRM_USER\/data:\/data/g" /home/$UCRM_USER/docker-compose.yml

		echo "Replacing env in docker compose."
		sed -i -e "s/POSTGRES_PASSWORD=ucrmdbpass1/POSTGRES_PASSWORD=$POSTGRES_PASSWORD/g" /home/$UCRM_USER/docker-compose.env
		sed -i -e "s/SECRET=changeThisSecretKey/SECRET=$SECRET/g" /home/$UCRM_USER/docker-compose.env

		change_ucrm_port
		change_ucrm_suspend_port
		enable_ssl
	fi
}

change_ucrm_port() {
	local PORT

	while true; do
		read -r -p "Do you want UCRM to be accessible on port 80? (Yes: recommended for most users, No: will set 8080 as default) [Y/n]: " PORT

		case $PORT in
			[yY][eE][sS]|[yY])
				sed -i -e "s/- 8080:80/- 80:80/g" /home/$UCRM_USER/docker-compose.yml
				echo "UCRM will start at 80 port."
				echo "#used only in instalation" >> /home/$UCRM_USER/docker-compose.env
				echo "SERVER_PORT=80" >> /home/$UCRM_USER/docker-compose.env
				break;;
			[nN][oO]|[nN])
				echo "UCRM will start at 8080 port. If you will change it, edit your docker-compose.yml in $UCRM_USER home direcotry."
				echo "#used only in instalation" >> /home/$UCRM_USER/docker-compose.env
				echo "SERVER_PORT=8080" >> /home/$UCRM_USER/docker-compose.env
				break;;
			*)
				;;
		esac
	done
}

change_ucrm_suspend_port() {
	local PORT

	while true; do
		read -r -p "Do you want UCRM suspend page to be accessible on port 81? (Yes: recommended for most users, No: will set 8081 as default) [Y/n]: " PORT

		case $PORT in
			[yY]*)
				sed -i -e "s/- 8081:81/- 81:81/g" /home/$UCRM_USER/docker-compose.yml
				echo "UCRM suspend page will start at 81 port."
				echo "#used only in instalation" >> /home/$UCRM_USER/docker-compose.env
				echo "SERVER_SUSPEND_PORT=81" >> /home/$UCRM_USER/docker-compose.env
				break;;
			[nN]*)
				echo "UCRM suspend page will start at 8081 port. If you will change it, edit your docker-compose.yml in $UCRM_USER home direcotry."
				echo "#used only in instalation" >> /home/$UCRM_USER/docker-compose.env
				echo "SERVER_SUSPEND_PORT=8081" >> /home/$UCRM_USER/docker-compose.env
				break;;
			*)
				;;
		esac
	done
}

enable_ssl() {
	local SSL

	while true; do
		read -r -p "Do you want to enable SSL? (You need to generate a certificate for yourself) [Y/n]: " SSL

		case $SSL in
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
	local SERVER_NAME

	read -r -p "Enter Server domain name for UCRM, for example ucrm.example.com: " SERVER_NAME
	echo "SERVER_NAME=$SERVER_NAME" >> /home/$UCRM_USER/docker-compose.env
}

change_ucrm_ssl_port() {
	local PORT

	while true; do
		read -r -p "Do you want UCRM SSL to be accessible on port 443? (Yes: recommended for most users, No: will set 8443 as default) [Y/n]: " PORT

		case $PORT in
			[yY]*)
				sed -i -e "s/- 8443:443/- 443:443/g" /home/$UCRM_USER/docker-compose.yml
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
	cd /home/$UCRM_USER && /usr/local/bin/docker-compose pull
}

start_docker_images() {
	echo "Starting docker images."
	cd /home/$UCRM_USER && /usr/local/bin/docker-compose up -d && /usr/local/bin/docker-compose ps
}

check_system
install_docker
install_docker_compose
create_user
download_docker_compose_files
download_docker_images
start_docker_images

exit 0
