#!/bin/bash

chmod +x *.sh

# install docker
./init-install-docker.sh

# init .env file and treafik
./init.sh

# editing .env file
nano .env

# add new user
./init-add-user.sh

# run our docker images
./update-all.sh

echo "[$0] Done."