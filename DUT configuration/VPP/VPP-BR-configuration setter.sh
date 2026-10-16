# VPP BR configuration setter script (to be used the BME R730 (TS1) with EA-Length = 13 bits)
# The version of VPP used: 24.02
#!/bin/bash

# setting ip addresses for both interfaces
vppctl set interface ip address eno1 2001:db8:6::1/64
vppctl set interface ip address eno2 2001:db8:7::1/64
vppctl set interface ip address eno2 203.0.113.1/24

# enabling the interfaces
vppctl set interface state eno1 up
vppctl set interface state eno2 up

# Adding a new MAP domain and a route to any simulated CE from that domain (suitable only for EA-bits = 13 , change settings for other EA-bits)
vppctl map add domain tag maptperf ip4-pfx 192.0.2.0/24 ip6-pfx 2001:db8:ce::/51 ip6-src 64:ff9b::/64 ea-bits-len 13 psid-offset 0 psid-len 5 mtu 0 #EA-bits=13
vppctl ip route add 2001:db8:ce::/51 via 2001:db8:6::2 eno1


# enabling map-t for both interfaces
vppctl map interface eno1 map-t
vppctl map interface eno2 map-t

# Setting Neighbor information
tester_l_mac="ec:f4:bb:ef:98:a0"
tester_l_dev="eno1"
tester_r_mac="ec:f4:bb:ef:98:a2"
tester_r_dev="eno2"
tester_l_ipv6="2001:db8:6::2"
tester_r_ipv6="2001:db8:7::2"
tester_r_ipv4="203.0.113.56"

vppctl set ip neighbor $tester_l_dev $tester_l_ipv6 $tester_l_mac static
vppctl set ip neighbor $tester_r_dev $tester_r_ipv6 $tester_r_mac static
vppctl set ip neighbor $tester_r_dev $tester_r_ipv4 $tester_r_mac static
