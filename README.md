# U CRM Billing Beta

## Installation

### 1. Install docker and docker-compose

- install docker with [docs.docker.com/engine/installation](https://docs.docker.com/engine/installation/)
- install docker-compose with [docs.docker.com/compose/install](https://docs.docker.com/compose/install/)

### 2. Download config files 
Download these two config files from this repository:
- [docker-compose.yml](https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.yml)
- [docker-compose.env](https://raw.githubusercontent.com/U-CRM/billing/master/docker-compose.env)

### 3. Modify docker-compose.yml file
It is recommended to store your CRM Billing database outside the docker container to enable easy upgrades and backups. To do so uncomment the postgres volumes section and verify or change the path to the database.
```
services:
  postgresql:
      volumes:
            - /home/docker/ucrm/
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

If your data is in `/home/docker/ucrm`, then you can backup this dir in home directory with:
```
docker pause ucrm
sudo tar -cvjSf ucrm.tar.bz2 ucrm
docker unpause ucrm
```
