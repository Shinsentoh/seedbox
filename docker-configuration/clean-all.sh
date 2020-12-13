#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source .env

docker-compose down --volumes
# rm -Rif $BASE_PATH
# deluser $MEDIA_USER