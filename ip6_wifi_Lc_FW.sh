#!/bin/bash

source 'ip6_wifi_h.sh'

# ---------------------------
# ログ用 チェーン
ip6tables -N Lc_FW_LOG
ip6tables -A Lc_FW_LOG -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_Lc_FW: '
ip6tables -A Lc_FW_LOG -j DROP
# ip6tables -A Lc_FW_LOG -j ACCEPT


# ---------------------------
# icmpv6 チェーン
ip6tables -N Lc_FW_icmpv6
# ip6tables -A Lc_FW_icmpv6 ! -s $zone_local -j Lc_FW_LOG

ip6tables -A Lc_FW_icmpv6 -p icmpv6 --icmpv6-type echo-request -j ACCEPT
ip6tables -A Lc_FW_icmpv6 -p icmpv6 --icmpv6-type echo-reply -j ACCEPT
# ip6tables -A Lc_FW_icmpv6 -p icmpv6 --icmpv6-type router-advertisement -j ACCEPT
ip6tables -A Lc_FW_icmpv6 -p icmpv6 --icmpv6-type router-solicitation -j ACCEPT
ip6tables -A Lc_FW_icmpv6 -p icmpv6 --icmpv6-type neighbour-advertisement -j ACCEPT
ip6tables -A Lc_FW_icmpv6 -p icmpv6 --icmpv6-type neighbour-solicitation -j ACCEPT
ip6tables -A Lc_FW_icmpv6 -p icmpv6 --icmpv6-type redirect -j ACCEPT

# Version 2 Multicast Listener Report
ip6tables -A Lc_FW_icmpv6 -p icmpv6 --icmpv6-type $icmpv6_V2_MLR -j ACCEPT

ip6tables -A Lc_FW_icmpv6 -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_Lc_FW_icmpv6: '
ip6tables -A Lc_FW_icmpv6 -j DROP
# ip6tables -A Lc_FW_icmpv6 -j ACCEPT


# ---------------------------
ip6tables -N Lc_FW
ip6tables -A Lc_FW -p icmpv6 -j Lc_FW_icmpv6


# DNS
ip6tables -A Lc_FW -p udp --dport $port_dns -j ACCEPT
ip6tables -A Lc_FW -p tcp --dport $port_dns -j ACCEPT

# http
ip6tables -A Lc_FW -p tcp -m multiport --dport $port_http,$port_https -j ACCEPT

#QUIC
ip6tables -A Lc_FW -p udp --dport $port_https -j ACCEPT

# NTP
ip6tables -A Lc_FW -p udp --dport $port_ntp -j ACCEPT

# DHCPv6（udp による host アドレス以外の情報取得）
# 547 に向けて発信すると、546 に返ってくる
ip6tables -A Lc_FW -p udp --dport 547 -d $DHCP_Relay -j ACCEPT

##### 注意： 546 への返信のルールは、まだ書いてない。fe80 で返ってくるかどうか分からないため


# LLMNR（サーバレス名前解決）
ip6tables -A Lc_FW -p udp --dport $port_LLMNR -d $DHCPv6_servers -j ACCEPT


# -----
ip6tables -A Lc_FW -j Lc_FW_LOG
# ip6tables -A Lc_FW -j ACCEPT
