#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

find ./ -type f -iname "*.sh" -exec chmod +x {} \;

echo "[$0] Starting docker installation ..."
./fresh-server-configuration/add-docker.sh
echo "[$0] Done with docker installation."

echo "[$0] Starting docker-seedbox configuration ..."
# init .env file and treafik
./docker-configuration/init.sh

source .env

docker network create traefik-network 2>&1 || true
./docker-configuration/update-all.sh

./docker-configuration/init-setup-nextcloud.sh

# todo: use cron to update ? OR is it handled by watchtower

echo "[$0] Done with docker-seedbox configuration."