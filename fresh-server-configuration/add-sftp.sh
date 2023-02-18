#!/bin/bash
# https://doc.ubuntu-fr.org/mysecureshell_sftp-server
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source ./fresh-server-configuration/.serverEnv

if [ "$ADD_SFTP" = true ] ; then
    echo "[$0] Adding Sftp server using openssh-server ..."
    apt install openssh-server &> ./logfile-seedbox-docker.log
    sed -i "s/#\?Port [[:digit:]]\+/Port ${SFTP_PORT}/g" /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "[$0] Sftp enabled, listening on port ${SFTP_PORT} ..."
fi