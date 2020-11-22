#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source .env

username=$MEDIA_USER

if ! id "$username" &>/dev/null; then
    echo "[$0] Creating user: $username ..."
    adduser $username

    PATH_TORRENTS=$BASE_PATH/torrents/.watch
    PATH_MEDIA=$BASE_PATH/media
    PATH_CONFIG=$BASE_PATH/config

    echo "[$0] Creating directories for $username ..."
    mkdir -p $PATH_TORRENTS $PATH_TORRENTS/movie $PATH_TORRENTS/music $PATH_TORRENTS/tv $PATH_TORRENTS/other $PATH_TORRENTS/software $PATH_TORRENTS/game $PATH_TORRENTS/vr $PATH_TORRENTS/book
    mkdir -p $BASE_PATH/torrents/download
    mkdir -p $BASE_PATH/torrents/complete
    cp -R $PATH_TORRENTS/* $BASE_PATH/torrents/download
    cp -R $PATH_TORRENTS/* $BASE_PATH/torrents/complete
    mkdir -p $PATH_MEDIA $PATH_MEDIA/movies $PATH_MEDIA/tvShows $PATH_MEDIA/musics $PATH_MEDIA/other $PATH_MEDIA/books $PATH_MEDIA/animes
    mkdir -p $PATH_CONFIG $PATH_CONFIG/plex $PATH_CONFIG/rutorrent $PATH_CONFIG/medusa $PATH_CONFIG/radarr $PATH_CONFIG/bazarr $PATH_CONFIG/jackett $PATH_CONFIG/lidarr $PATH_CONFIG/deluge $PATH_CONFIG/tautulli $PATH_CONFIG/jdownloader $PATH_CONFIG/nextcloud-db $PATH_CONFIG/nextcloud $PATH_CONFIG/nextcloud-data $PATH_CONFIG/duplicati
    mkdir -p $PATH_CONFIG/traefik $PATH_CONFIG/traefik/behaviour
    cp -R ./traefik/* $PATH_CONFIG/traefik/behaviour
    echo "[$0] settings directories to be owned by $username ..."
    chown -R $username:$username $BASE_PATH # make all directory owned by user $username
else
    mkdir -p $PATH_TORRENTS
    mkdir -p $PATH_MEDIA
    mkdir -p $PATH_CONFIG
fi

#echo "[$0] adding $username to group docker ..."
adduser $username docker

# below not needed as each shell file will source .env
# MEDIA_GID=$(id $username -g)
# MEDIA_UID=$(id $username -u)

# sed -i -e "s/PGID=[[:digit:]]*/PGID=$MEDIA_GID/g" .env
# sed -i -e "s/PUID=[[:digit:]]*/PUID=$MEDIA_UID/g" .env

echo "[$0] Done."
exit 0
