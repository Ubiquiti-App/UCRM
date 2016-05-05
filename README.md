# U CRM Billing Beta

## Installation 
Please follow this [Installation guide](https://github.com/U-CRM/billing/wiki/Installation-guide)

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
