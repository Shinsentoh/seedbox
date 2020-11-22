#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

chmod +x *.sh

# install docker
./install-docker.sh

# init .env file and treafik
./init.sh

source .env

docker network create traefik-network 2>&1 || true
./update-all.sh

#./init-setup-nextcloud.sh

# back as previous user
echo "[$0] Done."