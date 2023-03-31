#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

./fresh-server-configuration/docker-config.sh

find ./ -type f -iname "*.sh" -exec chmod +x {} \;

echo "[$0] Starting docker installation ..."
./fresh-server-configuration/add-docker.sh
if [ $? -ne 0 ]; then
    echo "[$0] Service docker is not running ... aborting script."
    exit 100
else
    echo "[$0] Done with docker installation."
fi

echo "[$0] Starting docker-seedbox configuration ..."

# copy docker aliases/functions to all users
cat ./docker-configuration/docker-aliases.sh >> /etc/bash.bashrc

source /etc/bash.bashrc

# init .env file and treafik
./docker-configuration/init.sh

source .env

docker network create traefik-network 2>&1 || true
./docker-configuration/update-all.sh

./docker-configuration/after-setup-nextcloud.sh

# todo: use cron to update ? OR is it handled by watchtower

echo "[$0] Done with docker-seedbox configuration."