#!/bin/bash

echo "[$0] Loading variables..."
source .env

echo "[$0] Installing nextcloud..."
docker exec -it -u abc -w /config/www/nextcloud \
  nextcloud bash -c " \
    php occ maintenance:install \
      --database \"mysql\" \
      --database-name \"${MYSQL_DATABASE}\" \
      --database-host \"nextcloud-db\" \
      --database-user \"${MYSQL_USER}\" \
      --database-pass \"${MYSQL_PASSWORD}\" \
      --admin-user \"${NEXTCLOUD_ADMIN_USER}\" \
      --admin-pass \"${NEXTCLOUD_ADMIN_PASSWORD}\" \
      --admin-email \"${ACME_MAIL}\" \
      --data-dir \"/data\" \
  "

# set the trusted domain to be able to use nextcloud
docker exec -it -u abc -w /config/www/nextcloud \
  nextcloud bash -c " \
    php occ config:system:set \
      trusted_domains 1 --value=${NEXTCLOUD_SUB_DOMAIN}.${TRAEFIK_DOMAIN} \
  "

echo "[$0] Done."