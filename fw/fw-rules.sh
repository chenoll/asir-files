#!/bin/sh

if [ $# -ne 1 ]
        then 
        echo "necesito un parámetro [ start | stop ]"
	exit 1
fi

case $1 in

"start")

#VARIABLES
DMZ_NET="172.20.110.0/24"
LAN_NET="192.168.110.0/24"

DMZ_TAR="ens3"
WAN_TAR="ens8"
LAN_TAR="ens9"

DMZ_IP="172.20.110.254"
WAN_IP="10.3.4.129"
LAN_IP="192.168.110.254"



#BORRAR REGLAS
iptables -F


#default policies

iptables -P INPUT DROP

iptables -P OUTPUT DROP

iptables -P FORWARD DROP

# SSH INPUT access rules: WAN

iptables -A INPUT -i $WAN_TAR -d $WAN_IP -p tcp --dport 2222 -j ACCEPT

iptables -A OUTPUT -o $WAN_TAR -s $WAN_IP -p tcp --sport 2222 -j ACCEPT

#LAN

iptables -A INPUT -i $LAN_TAR -d $LAN_IP -p tcp --dport 2222 -j ACCEPT

iptables -A OUTPUT -o $LAN_TAR -s $LAN_IP -p tcp --sport 2222 -j ACCEPT

#DMZ

iptables -A INPUT -i $DMZ_TAR -d $DMZ_IP -p tcp --dport 2222 -j ACCEPT

iptables -A OUTPUT -o $DMZ_TAR -s $DMZ_IP -p tcp --sport 2222 -j ACCEPT


#DHCP

iptables -A OUTPUT -o $WAN_TAR -p udp --dport 67 --sport 68 -j ACCEPT
iptables -A INPUT -i $WAN_TAR -p udp --sport 67 --dport 68 -j ACCEPT



#REGLA 8
iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p tcp --dport 22 -j ACCEPT
#REGLA 9
iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p udp --dport 53 -j ACCEPT
#REGLA 10
iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p tcp --dport 80 -j ACCEPT
#REGLA 11
iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p tcp --dport 443 -j ACCEPT
#REGLA 12
#iptables -A
#REGLAS 13
iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p tcp --dport 80 -i ens8 -j ACCEPT
#REGLAS 14

iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p tcp --dport 443 -i ens8 -j ACCEPT
#REGLA FIREWALL-DNS-DMZ
iptables -A OUTPUT -o $DMZ_TAR -s $DMZ_IP -p udp --dport 53 -d  172.20.115.22 -j ACCEPT
iptables -A INPUT -i $DMZ_TAR -d $DMZ_IP -p udp --sport 53 -s 172.20.115.22 -j ACCEPT
#REGLA FIREWALL-DNS-WAN
iptables -A OUTPUT -o $WAN_TAR -s $WAN_IP -p udp --dport 53 -j ACCEPT
iptables -A INPUT -i $WAN_TAR -d $WAN_IP -p udp --sport 53 -j ACCEPT


#REGLA POSTFORWARDING
iptables -t nat -A PREROUTING -i $WAN_TAR -p tcp --dport 80 -j DNAT --to 172.20.111.22
#REGLAS PREROUTING
iptables -t nat -A PREROUTING -i $WAN_TAR -d 10.3.4.193 -p tcp --dport 22 -j DNAT --to 172.20.111.22
iptables -A FORWARD -i $WAN_TAR -o $DMZ_TAR -p tcp --dport 22 -d 172.20.111.22 -j ACCEPT
iptables -A FORWARD -i $DMZ_TAR -o $WAN_TAR -p tcp --sport 22 -s 172.20.111.22 -j ACCEPT


#PREGUNTA Y RESPUESTA DEL SSH EXTERIOR-WAN
iptables -A INPUT -i $WAN_TAR -d $WAN_IP -p TCP --dport 2222 -j ACCEPT
iptables -A OUTPUT -o $WAN_TAR -m state --state ESTABLISHED,RELATED -p TCP --dport 2222 -j ACCEPY

#PREGUNTA Y RESPUESTA DEL SSH WAN-LAN
iptables -A INPUT -i $LAN_TAR -d $LAN_IP -p tcp --dport 2222 -j ACCEPT
iptables -A OUTPUT -o $LAN_TAR -m state --state ESTABLISHED,RELATED -p tcp --sport 2222 -j ACCEPT

#PREGUNTA Y RESPUESTA DEL SSH LAN-DMZ
iptables -A INPUT -i $DMZ_TAR -d $DMZ_IP -p tcp --dport 2222 -j ACCEPT
iptables -A OUTPUT -o $DMZ_TAR -m state --state ESTABLISHED,RELATED -p tcp --sport 2222 -j ACCEPT
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




