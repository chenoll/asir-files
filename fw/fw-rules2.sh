#!/bin/sh

if [ $# -ne 1 ]
        then 
        echo "necesito un parámetro [ start | stop ]"
exit 1
fi

case $1 in

"start")

#default policies

iptables -P INPUT DROP

iptables -P OUTPUT DROP

iptables -P FORWARD DROP

# SSH INPUT access rules: WAN

iptables -A INPUT -i ens8 -d 10.3.4.179 -p tcp --dport 2222 -j ACCEPT

iptables -A OUTPUT -o ens8 -s 10.3.4.179 -p tcp --sport 2222 -j ACCEPT

#LAN

iptables -A INPUT -i ens9 -d 192.168.115.254 -p tcp --dport 2222 -j ACCEPT

iptables -A OUTPUT -o ens9 -s 192.168.115.254 -p tcp --sport 2222 -j ACCEPT

#DMZ

iptables -A INPUT -i ens3 -d 172.20.115.100 -p tcp --dport 2222 -j ACCEPT

iptables -A OUTPUT -o ens3 -s 172.20.115.100 -p tcp --sport 2222 -j ACCEPT


#DHCP

iptables -A OUTPUT -o ens8 -p udp --dport 67 --sport 68 -j ACCEPT
iptables -A INPUT -i ens8 -p udp --sport 67 --dport 68 -j ACCEPT



#REGLA 8
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p tcp --dport 22 -j ACCEPT
#REGLA 9
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p udp --dport 53 -j ACCEPT
#REGLA 10
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p tcp --dport 80 -j ACCEPT
#REGLA 11
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p tcp --dport 443 -j ACCEPT
#REGLA 12
#iptables -A
#REGLAS 13
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p tcp --dport 80 -i ens8 -j ACCEPT
#REGLAS 14

iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p tcp --dport 443 -i ens8 -j ACCEPT
#REGLA FIREWALL-DNS-DMZ
iptables -A OUTPUT -o ens3 -s 172.20.115.254 -p udp --dport 53 -d  172.20.115.22 -j ACCEPT
iptables -A INPUT -i ens3 -d 172.20.115.254 -p udp --sport 53 -s 172.20.115.22 -j ACCEPT
#REGLA FIREWALL-DNS-WAN
iptables -A OUTPUT -o ens8 -s 10.3.4.179 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -i ens8 -d 10.3.4.179 -p udp --sport 53 -j ACCEPT

;;

"stop")

iptables -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

;;

*)

echo "se necesita un parametro valido [start | stop]"
exit

;;


esac
exit 0




