#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

echo "[$0] Initializing..."

if [[ ! -f .env ]]; then
  cp .env.sample .env
fi

if [[ ! "$EDITOR" = "nano" ]]; then
  while true; do
      read -p "Would you like to make nano your default editor ? [y/n]: " yn
      case $yn in
          [Yy]* ) apt-get install nano;
                  EDITOR=nano;
                  break;;
          [Nn]* ) break;;
          * ) echo "Please answer yes or no.";;
      esac
  done
fi

# editing .env file
read -s -p "Press {Enter} to edit the .env file"
"${EDITOR:-vi}" .env
source .env

# add new user
./docker-configuration/init-add-user.sh

echo "[$0] Done."