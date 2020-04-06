#!/bin/bash

source 'ip6_wifi_h.sh'

# ---------------------------
# ログ用 チェーン
ip6tables -N Cmn_OUT_LOG
ip6tables -A Cmn_OUT_LOG -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_Cmn_OUT: '
ip6tables -A Cmn_OUT_LOG -j DROP
# ip6tables -A Cmn_OUT_LOG -j ACCEPT


# ---------------------------
# icmpv6 チェーン
ip6tables -N Cmn_OUT_icmpv6
ip6tables -A Cmn_OUT_icmpv6 ! -d $zone_local -j Cmn_OUT_LOG

ip6tables -A Cmn_OUT_icmpv6 -p icmpv6 --icmpv6-type echo-request -j ACCEPT
ip6tables -A Cmn_OUT_icmpv6 -p icmpv6 --icmpv6-type echo-reply -j ACCEPT
# ip6tables -A Cmn_OUT_icmpv6 -p icmpv6 --icmpv6-type router-advertisement -j ACCEPT
ip6tables -A Cmn_OUT_icmpv6 -p icmpv6 --icmpv6-type router-solicitation -j ACCEPT
ip6tables -A Cmn_OUT_icmpv6 -p icmpv6 --icmpv6-type neighbour-advertisement -j ACCEPT
ip6tables -A Cmn_OUT_icmpv6 -p icmpv6 --icmpv6-type neighbour-solicitation -j ACCEPT
ip6tables -A Cmn_OUT_icmpv6 -p icmpv6 --icmpv6-type redirect -j ACCEPT

ip6tables -A Cmn_OUT_icmpv6 -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_Cmn_OUT_icmpv6: '
ip6tables -A Cmn_OUT_icmpv6 -j DROP
# ip6tables -A Cmn_OUT_icmpv6 -j ACCEPT


# ---------------------------
ip6tables -N Cmn_OUT
ip6tables -A Cmn_OUT -p icmpv6 -j Cmn_OUT_icmpv6

# DNS（apt で利用）
ip6tables -A Cmn_OUT -p udp --dport $port_dns -j ACCEPT

# http（apt で利用）
ip6tables -A Cmn_OUT -p tcp -m multiport --dport $port_http,$port_https -j ACCEPT

# NTP
ip6tables -A Cmn_OUT -p udp --dport $port_ntp -j ACCEPT

# DHCPv6（udp による host アドレス以外の情報取得）
# 547 に向けて発信すると、546 に返ってくる
ip6tables -A Cmn_OUT -p udp --dport 547 -d ff02::1:2 -j ACCEPT


# -----
ip6tables -A Cmn_OUT -j Cmn_OUT_LOG
# ip6tables -A Cmn_OUT -j NFLOG --nflog-group 0 --nflog-prefix 'CHK_Cmn_OUT: '
# ip6tables -A Cmn_OUT -j ACCEPT
