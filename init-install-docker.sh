#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

. ./tools.lib

# docker
if ! command -v docker &> /dev/null; then
    echo "[$0] Adding the GPG key for the official Docker repository to your system ..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo "[$0] Adding the Docker repository to APT sources ..."
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    echo "[$0] updating the package database with the Docker packages from the newly added repo ..."
    apt-get update &> logfile.txt

    echo "[$0] Making sure you are about to install from the Docker repo instead of the default Ubuntu repo ..."
    apt-cache policy docker-ce &> logfile.txt

    echo "[$0] Installing Docker ..."
    apt-get install -y docker-ce &> logfile.txt

    echo "[$0] Checking that docker is running ..."
    systemctl status docker
else
    echo "[$0] docker is already installed."
fi

# docker-compose
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(getGithubLatestRelease "docker/compose")
    echo "[$0] Installing docker-compose version $DOCKER_COMPOSE_VERSION ..."
    curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose

    echo "[$0] Settings permissions to execute /usr/local/bin/docker-compose ..."
    chmod +x /usr/local/bin/docker-compose

    echo "[$0] check docker-compose version installed ..."
    docker-compose --version
else
    echo "[$0] docker-compose is already installed."
fi

# local-persist Docker plugin
# This is a volume plugin that extends the default local driver’s functionality by allowing you specify a mountpoint anywhere on the host,
# which enables the files to always persist, even if the volume is removed via docker volume rm
serviceName=docker-volume-local-persist
if systemctl --all --type service | grep -q "$serviceName"; then
    echo "[$0] service $serviceName exists."
else
    echo "[$0] Installing local-persist Docker plugin."
    curl -fsSL https://raw.githubusercontent.com/MatchbookLab/local-persist/master/scripts/install.sh | sudo bash
fi

echo "[$0] Done."
exit 0

