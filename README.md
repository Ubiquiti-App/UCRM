# U CRM Billing Beta

## Installation Ubuntu

Run user with sudo:

```
curl -fsSL https://raw.githubusercontent.com/U-CRM/billing/master/ucrm_install_ubuntu.sh | sudo sh
```

## Installation Debian

```
su root
apt-get update && apt-get install curl -y && curl -fsSL https://raw.githubusercontent.com/U-CRM/billing/master/ucrm_install_debian.sh | sh
```

## Installation on other systems

### 1. Install docker and docker-compose

- install docker with [docs.docker.com/engine/installation](https://docs.docker.com/engine/installation/)
- install docker-compose with [docs.docker.com/compose/install](https://docs.docker.com/compose/install/)

### 2. Download config files 
Download these two config files from this repository:
- [docker-compose.yml](https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.yml)
- [docker-compose.env](https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.env)

### 3. Modify docker-compose.yml file
It is recommended to store your CRM Billing database outside the docker container to enable easy upgrades and backups. To do so uncomment the postgres volumes section and verify or change the path to the database. Uncomment and change all volumes sections.
```
services:
  postgresql:
    volumes:
      - /change/this/path/postgres:/var/lib/postgresql/data
```
- UCRM will start on ports 8080 (the application) and 8081 (suspend page) but you can modify it in this config file.

### 4. Start UCRM
```
$ docker-compose up -d
```

At the first start postgresql creates the database, it can take several seconds.

UCRM will start on ports 8080 and 8081 unless you changed it in the docker-compose.yml file.

Default login and password to the CRM Billing app is `admin/admin`.


## Backup

For data backup, you must first pause the running containers. Go to directory, where your docker-compose.yml is located (probably `/home/ucrm`).
Then archive the data and save it somewhere safe and finally unpause the containers.

```
cd /home/ucrm
docker-compose pause
sudo tar -cvjSf ucrm-data.tar.bz2 data
sudo tar -cvjSf ucrm-postgres.tar.bz2 postgres
docker-compose unpause
```

This set of commands will create separate archives for U CRM data (e.g. invoice PDFs) and database.
