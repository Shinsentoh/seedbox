#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source ./fresh-server-configuration/.serverEnv

if [ "$ADD_USER" = true ] ; then
    # if id -u "$SYSTEM_USER" >/dev/null 2>&1; then
        # creates user and his home directory
        /usr/sbin/adduser $SYSTEM_USER
        # add user to group sudo to be able to run root commands
        usermod -aG sudo $SYSTEM_USER
    # fi
fi

if [ "$ADD_ALIASES_TO_USER_SHELL" = true ] ; then
    # if id -u "$SYSTEM_USER" >/dev/null 2>&1; then
        # copy aliases into the user bashrc to have them for later
        cat ./fresh-server-configuration/aliases.sh >> /home/$SYSTEM_USER/.bashrc
    # fi
fi