#!/bin/bash

chmod +x *.sh

# install docker
./init-install-docker.sh

# init .env file and treafik
./init.sh

echo "login as user '$MEDIA_USER' to perform docker operations"
CUR_USER=$(whoami)

if [ $CUR_USER != $MEDIA_USER ]; then
    # log as MEDIA_USER, add the traefik network and run our docker images
exec sudo -i -u $MEDIA_USER /bin/bash - << eof
    docker network create traefik-network 2>&1 || true
    ./update-all.sh
    exit 0
eof
else
    docker network create traefik-network 2>&1 || true
    ./update-all.sh
fi

# back as previous user
echo "[$0] Done."