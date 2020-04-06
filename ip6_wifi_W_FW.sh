#!/bin/bash

source 'ip6_wifi_h.sh'

# ---------------------------
# ログ用 チェーン
ip6tables -N W_FW_LOG
ip6tables -A W_FW_LOG -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_W_FW: '
ip6tables -A W_FW_LOG -j DROP
# ip6tables -A W_FW_LOG -j ACCEPT


# ---------------------------
# icmpv6 チェーン
ip6tables -N W_FW_icmpv6
ip6tables -A W_FW_icmpv6 ! -s $zone_local -j W_FW_LOG

ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type echo-request -j ACCEPT
ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type echo-reply -j ACCEPT
ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type router-advertisement -j ACCEPT
ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type router-solicitation -j ACCEPT
ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type neighbour-advertisement -j ACCEPT
ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type neighbour-solicitation -j ACCEPT
ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type redirect -j ACCEPT

ip6tables -A W_FW_icmpv6 -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_W_FW_icmpv6: '
ip6tables -A W_FW_icmpv6 -j DROP
# ip6tables -A W_FW_icmpv6 -j ACCEPT


# ---------------------------
ip6tables -N W_FW
ip6tables -A W_FW -p icmpv6 -j W_FW_icmpv6

# WAN 側から、TCP, UDP の新規 FORWARD を通すことはないはず

# DNS
# ip6tables -A W_FW -p udp --dport $port_dns -j ACCEPT

# http
# ip6tables -A W_FW -p tcp -m multiport --dport $port_http,$port_https -j ACCEPT

#QUIC
# ip6tables -A W_FW -p udp --dport $port_https -j ACCEPT

# NTP
# ip6tables -A W_FW -p udp --dport $port_ntp -j ACCEPT

ip6tables -A W_FW -j W_FW_LOG
# ip6tables -A W_FW -j ACCEPT

