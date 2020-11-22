#!/bin/bash

# Create/update http_auth file according to values in .env file
source .env
echo "${HTTP_USER}:${HTTP_PASSWORD}" > ${BASE_PATH}/config/traefik/behaviour/http_auth
chown -R seedbox:seedbox ${BASE_PATH}

#echo "[$0] ***** Pulling all images... *****"
#docker-compose pull
echo "[$0] ***** Recreating containers if required... *****"
docker-compose up -d --remove-orphans
echo "[$0] ***** Done updating containers *****"
echo "[$0] ***** Clean unused images... *****"
docker image prune -af
echo "[$0] ***** Done! *****"
exit 0