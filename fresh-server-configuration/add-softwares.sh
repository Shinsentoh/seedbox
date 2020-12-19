#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source fresh-server-configuration/.serverEnv

apt-get install curl net-tools sudo software-properties-common &> ./logfile-seedbox-docker.log

