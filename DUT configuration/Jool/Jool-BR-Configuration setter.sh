# Jool BR configuration setter script (to be used for Jool at the BME R730 (TS1) with EA-Length = 13 bits)
# The version of Jool used: 4.1.255.3 (distributed as 4.2.0-rc2)
#!/bin/bash

ip link set eno1 up
ip address add 2001:db8:6::1/64 dev eno1

ip link set eno2 up
ip address add 2001:db8:7::1/64 dev eno2

#ip link set eno2 up
ip address add 203.0.113.1/24 dev eno2

ip route add 2001:db8:ce::/51 via 2001:db8:6::2
ip route add 2001:db8:6::2/128 dev eno1
ip route add 2001:db8:7::2/128 dev eno2

sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1

#JOOL BR
/sbin/modprobe jool_mapt
jool_mapt instance add "BR" --iptables --dmr 64:ff9b::/64
jool_mapt -i "BR" fmrt add 2001:db8:ce::/51 192.0.2.0/24 13 0
jool_mapt -i "BR" global update map-t-type BR
jool_mapt -i "BR" global update lowest-ipv6-mtu 1518
#jool_mapt -i "BR" global display

#iptables
ip6tables -t mangle -A PREROUTING -s 2001:db8:ce::/51 -d 64:ff9b::/64 -j JOOL_MAPT --instance "BR"
iptables -t mangle -A PREROUTING -s 203.0.113.0/24 -d 192.0.2.0/24 -j JOOL_MAPT --instance "BR"

tester_l_mac="ec:f4:bb:ef:98:a0"
tester_l_dev="eno1"
tester_l_ipv6="2001:db8:6::2"
tester_r_mac="ec:f4:bb:ef:98:a2"
tester_r_dev="eno2"
tester_r_ipv4="203.0.113.56"
tester_r_ipv6="2001:db8:7::2"

ip neighbor add $tester_l_ipv6 lladdr $tester_l_mac dev $tester_l_dev nud permanent
ip neighbor add $tester_r_ipv6 lladdr $tester_r_mac dev $tester_r_dev nud permanent
ip neighbor add $tester_r_ipv4 lladdr $tester_r_mac dev $tester_r_dev nud permanent
