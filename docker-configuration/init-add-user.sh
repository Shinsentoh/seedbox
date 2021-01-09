#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source .env

username=$MEDIA_USER
PATH_TORRENTS=$BASE_PATH/$TORRENT_DIR_NAME
PATH_MEDIA=$BASE_PATH/$MEDIA_DIR_NAME
PATH_CONFIG=$BASE_PATH/$CONFIG_DIR_NAME
SCRIPT_DIR=$(pwd)

if ! id "$username" &>/dev/null; then
    echo "[$0] Creating user: $username ..."
    /usr/sbin/adduser $username
fi

echo "[$0] Creating directories for $username ..."
# backup folder
mkdir -p $BASE_PATH/$BACKUP_DIR_NAME
# torrents folder
mkdir -p $PATH_TORRENTS/$TORRENTS_TREE
# media folder
mkdir -p $PATH_MEDIA/$MEDIA_TREE
# config folder
mkdir -p $PATH_CONFIG/$CONFIG_TREE
# tautulli needs access to the plex logs
mkdir -p $PATH_CONFIG/plex/Library/Application\ Support/Plex\ Media\ Server/Logs/
# traefik configuration
mkdir -p $PATH_CONFIG/traefik/behaviour
cp -R ./traefik/* $PATH_CONFIG/traefik/behaviour
touch $PATH_CONFIG/traefik/acme.json && chmod 600 $PATH_CONFIG/traefik/acme.json

echo "[$0] settings directories to be owned by $username ..."
chown -R $username:$username $BASE_PATH # make all directory owned by user $username

MEDIA_GID=$(id $username -g)
MEDIA_UID=$(id $username -u)

echo "[$0] Setting user UID and GID in the .env file for $username ..."
sed -i -e "s/PGID=[[:digit:]]*/PGID=$MEDIA_GID/g" .env
sed -i -e "s/PUID=[[:digit:]]*/PUID=$MEDIA_UID/g" .env

TMP_NETDATA_DOCKER_PGID=$(grep docker /etc/group | cut -d ':' -f 3)
sed -i -e "s/NETDATA_DOCKER_PGID=[[:digit:]]*/NETDATA_DOCKER_PGID=$TMP_NETDATA_DOCKER_PGID/g" .env

/usr/sbin/adduser $username docker

echo "[$0] Done."
exit 0
