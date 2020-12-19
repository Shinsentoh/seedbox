#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

. libs/tools.lib

# docker
if ! command -v docker &> /dev/null; then
    echo "[$0] Adding the GPG key for the official Docker repository to your system ..."
    linux_os_name=$(lsb_release -is | tr "[:upper:]" "[:lower:]")
    curl -fsSL https://download.docker.com/linux/$linux_os_name/gpg | apt-key add -

    echo "[$0] Adding the Docker repository to APT sources ..."
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$linux_os_name $(lsb_release -cs) stable"

    echo "[$0] updating the package database with the Docker packages from the newly added repo ..."
    apt-get update &> ./logfile-seedbox-docker.log

    echo "[$0] Making sure you are about to install from the Docker repo instead of the default Ubuntu repo ..."
    apt-cache policy docker-ce &> ./logfile-seedbox-docker.log

    echo "[$0] Installing Docker ..."
    apt-get install -y docker-ce &> ./logfile-seedbox-docker.log

    ANY_SERVICE_STATUS="$(isRunningService docker)"
    if [ $ANY_SERVICE_STATUS -ne 0 ]; then
        exit 100
    else
        echo "[$0] service docker installed."
    fi
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
ANY_SERVICE_STATUS=$(isInstalledService "$serviceName")
if [ $ANY_SERVICE_STATUS -eq 0 ]; then
    echo "[$0] service $serviceName is already installed."
else
    echo "[$0] Installing local-persist Docker plugin."
    curl -fsSL https://raw.githubusercontent.com/MatchbookLab/local-persist/master/scripts/install.sh | bash &> ./logfile-seedbox-docker.log
    ANY_SERVICE_STATUS=$(isInstalledService "$serviceName")
    if [ $ANY_SERVICE_STATUS -ne 0 ]; then
        exit 100
    else
        echo "[$0] service $serviceName installed."
    fi
fi

echo "[$0] Done."
exit 0

