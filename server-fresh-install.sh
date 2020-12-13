#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

echo "[$0] Done with server configuration."

find ./ -type f -iname "*.sh" -exec chmod +x {} \;

if [[ ! -f ./fresh-server-configuration/.serverEnv ]]; then
  cp ./fresh-server-configuration/.serverEnv.sample ./fresh-server-configuration/.serverEnv
fi

if [ ${EDITOR} != "nano" ]; then
  while true; do
      read -p "Would you like to make nano your default editor ?" yn
      case $yn in
          [Yy]* ) apt-get install nano;
                  EDITOR=nano;
                  break;;
          [Nn]* ) break;;
          * ) echo "Please answer yes or no.";;
      esac
  done
fi

# editing .serverEnv file
read -s -p "Press {Enter} to edit the .serverEnv file"
"${EDITOR:-vi}" ./fresh-server-configuration/.serverEnv
source ./fresh-server-configuration/.serverEnv

# add needed softwares to run all the scripts
./fresh-server-configuration/add-softwares.sh
# add user
./fresh-server-configuration/add-user.sh
# add sftp
./fresh-server-configuration/add-sftp.sh
# can be run before the docker installation
./fresh-server-configuration/docker-config.sh

# install docker, setup the user folders and run the containers
./docker-fresh-install.sh

# add and configure the firewall
./fresh-server-configuration/add-firewall.sh

# back as previous user
echo "[$0] Done with server configuration."