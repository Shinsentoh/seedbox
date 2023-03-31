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
PATH_GAMES=$BASE_PATH/$GAMES_DIR_NAME
PATH_WATCH_DIR=$PATH_TORRENTS/$WATCH_DIR_NAME
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
# games folder
mkdir -p $PATH_GAMES/$GAMES_TREE
# config folder
mkdir -p $PATH_CONFIG/$CONFIG_TREE
# tautulli needs access to the plex logs
PLEX_FOLDER=$PATH_CONFIG/plex/Library/Application\ Support/Plex\ Media\ Server
mkdir -p "$PLEX_FOLDER"/Logs/
# plex
mkdir -p "$PLEX_FOLDER"/Scanners/Series/
mkdir -p "$PLEX_FOLDER"/Plug-ins/
# plex anime agent
wget -O "$PLEX_FOLDER"/Scanners/Series/Absolute\ Series\ Scanner.py https://raw.githubusercontent.com/ZeroQI/Absolute-Series-Scanner/master/Scanners/Series/Absolute%20Series%20Scanner.py
wget -O "$PLEX_FOLDER"/Plug-ins/Hama.bundle.zip https://github.com/ZeroQI/Hama.bundle/archive/refs/heads/master.zip
unzip "$PLEX_FOLDER"/Plug-ins/Hama.bundle.zip -d "$PLEX_FOLDER"/Plug-ins/
mv "$PLEX_FOLDER"/Plug-ins/Hama.bundle-master "$PLEX_FOLDER"/Plug-ins/Hama.bundle
rm -rf "$PLEX_FOLDER"/Plug-ins/Hama.bundle.zip
# plex subtitle plugin
wget -O "$PLEX_FOLDER"/Plug-ins/Sub-Zero.bundle.zip https://github.com/pannal/Sub-Zero.bundle/archive/refs/heads/master.zip
unzip "$PLEX_FOLDER"/Plug-ins/Sub-Zero.bundle.zip -d "$PLEX_FOLDER"/Plug-ins/
mv "$PLEX_FOLDER"/Plug-ins/Sub-Zero.bundle-master "$PLEX_FOLDER"/Plug-ins/Sub-Zero.bundle
rm -rf "$PLEX_FOLDER"/Plug-ins/Sub-Zero.bundle.zip

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

cp ./script.d/magnet2torrent.sh  $PATH_TORRENTS/
sed -i -e "s/watchdir=#ROOT_WATCH_DIR#/watchdir=$PATH_WATCH_DIR/g" $PATH_TORRENTS/magnet2torrent.sh
chmod +x $PATH_TORRENTS/magnet2torrent.sh

# add magnet2torrent to cron
(crontab -l; echo "1 * * * * $PATH_TORRENTS/magnet2torrent.sh >/dev/null 2>&1") | sort -u | crontab -

/usr/sbin/adduser $username docker

# add aliases specific to MEDIA_USER for all users
echo 'alias fixru="sudo rm -Rf $PATH_TORRENTS/.session/*.lock & docker restart rutorrent"' >> /etc/bash.bashrc
echo 'alias ..s="cd $BASE_PATH"' >> /etc/bash.bashrc
echo 'alias ..sc="cd $PATH_CONFIG"' >> /etc/bash.bashrc
echo 'alias ..st="cd $PATH_TORRENTS"' >> /etc/bash.bashrc

echo "[$0] Done."
exit 0
