#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source .env

docker-compose down
rm -i -R $BASE_PATH
deluser $MEDIA_USER