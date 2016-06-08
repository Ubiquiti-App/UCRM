#!/bin/sh

lsb_dist=''
dist_version=''

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

if [ "$lsb_dist" = "ubuntu" ] && [ "$dist_version" = "xenial" ]; then
	curl -fsSL https://raw.githubusercontent.com/U-CRM/billing/master/ucrm_install_ubuntu.sh > /tmp/ucrm_install_ubuntu.sh && \
	sudo bash /tmp/ucrm_install_ubuntu.sh && \
	rm /tmp/ucrm_install_ubuntu.sh && \
	rm /tmp/ucrm_install.sh
elif [ "$lsb_dist" = "debian" ] && [ "$dist_version" = "8" ]; then
	curl -fsSL https://raw.githubusercontent.com/U-CRM/billing/master/ucrm_install_debian.sh > /tmp/ucrm_install_debian.sh && \
	bash /tmp/ucrm_install_debian.sh && \
	rm /tmp/ucrm_install_debian.sh && \
	rm /tmp/ucrm_install.sh
else
	echo "Unsupported distro."
	echo "Supported was: Ubuntu Xenial and Debian 8."
	echo $lsb_dist
	echo $dist_version
fi

exit 0
