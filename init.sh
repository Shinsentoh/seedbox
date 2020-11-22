#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

echo "[$0] Initializing..."

if [[ ! -f .env ]]; then
  cp .env.sample .env
fi

# editing .env file
read -s -p "Press {Enter} to edit the .env file"
nano .env
source .env

# add new user
./init-add-user.sh

echo "[$0] Done."