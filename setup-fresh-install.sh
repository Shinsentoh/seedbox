#!/bin/bash

chmod +x *.sh

# install docker
./init-install-docker.sh

# init .env file and treafik
./init.sh

# run our docker images
./update-all.sh

echo "[$0] Done."
exit 0