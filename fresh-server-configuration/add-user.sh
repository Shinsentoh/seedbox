#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source ./fresh-server-configuration/.serverEnv

if [ ! id "$USER" &>/dev/null ] ; then
    if [ "$ADD_USER" = true ] ; then
        # creates user and his home directory
        /usr/sbin/adduser $USER
        # add user to group sudo to be able to run root commands
        usermod -aG sudo $USER
    fi
fi

if [ "$ADD_ALIASES_TO_USER_SHELL" = true ] ; then
    # copy aliases into the user bashrc to have them for later
    cat ./fresh-server-configuration/aliases.sh >> /home/$USER/.bashrc
fi