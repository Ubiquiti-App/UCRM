# U CRM Billing Beta

## Installation

### 1. Install docker and docker-compose

- install docker with [docs.docker.com/engine/installation](https://docs.docker.com/engine/installation/)
- install docker-compose with [docs.docker.com/compose/install](https://docs.docker.com/compose/install/)

### 2. Download config files 
- docker-compose.yml
- docker-compose.env
UCRM will start on ports 8080 (the application) and 8081 (suspend page). You can change it in docker-compose.yml file.

### 3. Start UCRM
```
$ docker-compose up -d
```

At the first start postgresql creates the database, it can take several seconds.

UCRM will start on ports 8080 and 8081 unless you changed it in the docker-compose.yml file.

Default login and password to the CRM Billing app is `admin\admin`.


## Backup

If your data is in `/home/docker/ucrm`, then you can backup this dir in home directory with:
```
docker pause ucrm
sudo tar -cvjSf ucrm.tar.bz2 ucrm
docker unpause ucrm
```
