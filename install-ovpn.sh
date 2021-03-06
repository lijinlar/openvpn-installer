ssh -i$1 -t ubuntu@$2 '\
git clone https://github.com/redgeoff/openvpn-server-vagrant \
&& cd openvpn-server-vagrant \
&& echo "#!/usr/bin/env bash
KEY_COUNTRY=\"IN\"
KEY_PROVINCE=\"KL\"
KEY_CITY=\"City\"
KEY_ORG=\"Organization\"
KEY_EMAIL=\"me@mymail.com\"
KEY_OU=\"OrganizationUnit\"
PUBLIC_IP=\"'$2'\"" >> config.sh \
&& sudo su - root <<EOFCMD 
/home/ubuntu/openvpn-server-vagrant/ubuntu.sh \
&& /home/ubuntu/openvpn-server-vagrant/openvpn.sh \
&& echo "
push \"redirect-gateway def1 bypass-dhcp\"
push \"dhcp-option DNS 8.8.8.8\"
push \"dhcp-option DNS 8.8.4.4\"" >> /etc/openvpn/server.conf \
&& echo "# Generated by iptables-save v1.6.0 on Fri Jul 10 13:59:09 2020
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -o tun+ -j MASQUERADE
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -s 0.0.0.0/2 -o eth0 -j MASQUERADE
-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
-A POSTROUTING -s 10.89.0.0/24 -o eth0 -j MASQUERADE
COMMIT
# Completed on Fri Jul 10 13:59:09 2020
# Generated by iptables-save v1.6.0 on Fri Jul 10 13:59:09 2020
*filter
:INPUT ACCEPT [1:52]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -s 127.0.0.0/8 ! -i lo -j REJECT --reject-with icmp-port-unreachable
-A INPUT -p icmp -m state --state NEW -m icmp --icmp-type 8 -j ACCEPT
-A INPUT -p icmp -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 22 -j ACCEPT
-A INPUT -i eth0 -p udp -m state --state NEW,ESTABLISHED -m udp --dport 1194 -j ACCEPT
-A INPUT -i eth0 -p udp -m state --state ESTABLISHED -m udp --sport 53 -j ACCEPT
-A INPUT -i eth0 -p tcp -m state --state ESTABLISHED -m tcp --sport 53 -j ACCEPT
-A INPUT -i eth0 -p tcp -m state --state ESTABLISHED -m tcp --sport 80 -j ACCEPT
-A INPUT -i eth0 -p tcp -m state --state ESTABLISHED -m tcp --sport 443 -j ACCEPT
-A INPUT -i tun0 -j ACCEPT
-A INPUT -m limit --limit 3/min -j LOG --log-prefix "iptables_INPUT_denied: "
-A INPUT -j REJECT --reject-with icmp-port-unreachable
-A FORWARD -i tun0 -j ACCEPT
-A FORWARD -s 10.89.0.0/24 -i tun0 -o eth0 -j ACCEPT
-A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -m limit --limit 3/min -j LOG --log-prefix "iptables_FORWARD_denied: "
-A FORWARD -j REJECT --reject-with icmp-port-unreachable
-A OUTPUT -o lo -j ACCEPT
-A OUTPUT -p icmp -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m state --state ESTABLISHED -m tcp --sport 22 -j ACCEPT
-A OUTPUT -o eth0 -p udp -m state --state ESTABLISHED -m udp --sport 1194 -j ACCEPT
-A OUTPUT -o eth0 -p udp -m state --state NEW,ESTABLISHED -m udp --dport 53 -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 53 -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 80 -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED -m tcp --dport 443 -j ACCEPT
-A OUTPUT -o tun0 -j ACCEPT
-A OUTPUT -m limit --limit 3/min -j LOG --log-prefix "iptables_OUTPUT_denied: "
-A OUTPUT -j REJECT --reject-with icmp-port-unreachable
COMMIT
# Completed on Fri Jul 10 13:59:09 2020 " > /etc/iptables/rules.v4 \
&& iptables -t nat -A POSTROUTING -s 10.89.0.0/24 -o eth0 -j MASQUERADE \
&& echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/99-sysctl.conf \
&& iptables-restore < /etc/iptables/rules.v4 \
&& sysctl -p \
&& systemctl restart openvpn@server \
&& systemctl restart openvpn \
&& /home/ubuntu/openvpn-server-vagrant/add-client.sh '$3' \
&& cp ~/client-configs/files/'$3'.ovpn /home/ubuntu/ 
EOFCMD'\
&& scp -i $1 ubuntu@$2:~/$3.ovpn ./