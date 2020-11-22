#!/bin/bash

echo "[$0] Initializing..."

if [[ ! -f .env ]]; then
  cp .env.sample .env
  echo "[$0] Please edit .env file"
fi

# editing .env file
nano .env
source .env

# add new user
./init-add-user.sh

echo "login as user $MEDIA_USER to perform docker operations"
su $MEDIA_USER

docker network create traefik-network 2>&1 || true

echo "[$0] Done."