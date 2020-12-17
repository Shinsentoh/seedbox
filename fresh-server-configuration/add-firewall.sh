#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run this script as root."
    exit
fi

source fresh-server-configuration/.serverEnv

if [ "$ADD_FIREWALL" = true ] ; then
    echo "[$0] Installing packages to manage the firewall (iptables)."
    # iproute2 iproute2-doc => command 'ss'
    # net-tools => command 'netstat'
    # iptables-persistent netfilter-persistent => play with the firewall and keep configuration on each reboot
    apt-get install iproute2 iproute2-doc net-tools iptables-persistent netfilter-persistent &> ./logfile-seedbox-docker.log
    # let's be sure it will be started again after reboot
    systemctl enable netfilter-persistent
    # not using this repo anymore in case it comes to an end one day, but feel free to use it instead of the local file if you want.
    #curl https://gist.githubusercontent.com/jirutka/3742890/raw/c9f6bdbfcf597578e562c92ea1e256a9ebcf3a2c/rules-both.iptables > basic-rules.iptables
    echo "[$0] Loading global rules to secure our server."
    # apply some basics rules
    iptables-restore < fresh-server-configuration/basic-rules.iptables
    echo "[$0] allowing all current listening ports into the firewall."
    # export all listening ports and protocol as iptables commands
    ss -lntu | tail -n+3 | awk '{gsub(/.*:/,"",$5) ; print "iptables -A INPUT -p" $1 " --dport " $5 " -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT" }' | sort -u -k5n -k3 > fresh-server-configuration/input-rules.sh
    chmod +x input-rules.sh
    # run the commands to open those ports
    ./fresh-server-configuration/input-rules.sh
    # save the whole configuration, so that it is restored on the each reboot
    netfilter-persistent save
    # clean temp files.
    rm fresh-server-configuration/basic-rules.iptables fresh-server-configuration/input-rules.sh
    echo "[$0] Done setting up the firewall."
    echo "DO NOT CLOSE or EXIT THIS SSH CONNECTION, before runnin the below test:"
    echo "Open another ssh connection to this server to make sure it is reachable through ssh with this new firewall configuration.".
    echo "If it's not working, run 'netfilter-persistent flush' to flush the rules and then 'netfilter-persistent save' to be sure you'll keep access to this server even after a reboot until you figure out why it's not working."

    echo "If you are lucky and your ssh connection is still working, you can either:"
    echo "edit /etc/network/if-pre-up.d/iptables.rules.v4 (and/or iptables.rules.v6) to add future rules and then run 'netfilter-persistent start' to load them"
    echo "OR add your rules from a terminal and run 'netfilter-persistent save' to keep the changes between reboots"
    echo "[$0] Done."
fi
