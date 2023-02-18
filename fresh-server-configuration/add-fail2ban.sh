#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source ./fresh-server-configuration/.serverEnv

# if [ "$ADD_FAIL2BAN" = true ] ; then
#     apt-get install fail2ban
#     cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
# fi