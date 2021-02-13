 # Steam
iptables -A INPUT -p tcp --dport 27015:27030 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --dport 27015:27030 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 27015 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --dport 27015 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
#
