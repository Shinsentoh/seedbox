#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source ./fresh-server-configuration/.serverEnv

if [ "$CHANGE_DOCKER_DEFAULT_IMAGES_LOCATION" = true ] ; then
    mkdir -p /etc/docker && cp ./fresh-server-configuration/docker-daemon-sample.json $_/daemon.json
    sed -i "s#/var/lib/docker#${NEW_DOCKER_IMAGES_LOCATION}#" /etc/docker/daemon.json
    ## will free space for the old containers
    # docker system prune -a
    ## reload docker to apply this location change
    # systemctl restart  docker
fi