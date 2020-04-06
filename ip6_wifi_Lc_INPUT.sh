#!/bin/bash

source 'ip6_wifi_h.sh'

# ---------------------------
# ログ用 チェーン
ip6tables -N Lc_INPUT_LOG
ip6tables -A Lc_INPUT_LOG -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_Lc_INPUT: '
ip6tables -A Lc_INPUT_LOG -j DROP
# ip6tables -A Lc_INPUT_LOG -j ACCEPT


# ---------------------------
# icmpv6 チェーン
ip6tables -N Lc_INPUT_icmpv6
# ip6tables -A Lc_INPUT_icmpv6 ! -s $zone_local -j Lc_INPUT_LOG

ip6tables -A Lc_INPUT_icmpv6 -p icmpv6 --icmpv6-type echo-request -j ACCEPT
ip6tables -A Lc_INPUT_icmpv6 -p icmpv6 --icmpv6-type echo-reply -j ACCEPT
# ip6tables -A Lc_INPUT_icmpv6 -p icmpv6 --icmpv6-type router-advertisement -j ACCEPT
# ip6tables -A Lc_INPUT_icmpv6 -p icmpv6 --icmpv6-type router-solicitation -j ACCEPT
ip6tables -A Lc_INPUT_icmpv6 -p icmpv6 --icmpv6-type neighbour-advertisement -j ACCEPT
ip6tables -A Lc_INPUT_icmpv6 -p icmpv6 --icmpv6-type neighbour-solicitation -j ACCEPT
ip6tables -A Lc_INPUT_icmpv6 -p icmpv6 --icmpv6-type redirect -j ACCEPT

ip6tables -A Lc_INPUT_icmpv6 -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_Lc_INPUT_icmpv6: '
ip6tables -A Lc_INPUT_icmpv6 -j DROP
# ip6tables -A Lc_INPUT_icmpv6 -j ACCEPT


# ---------------------------
ip6tables -N Lc_INPUT
ip6tables -A Lc_INPUT -p icmpv6 -j Lc_INPUT_icmpv6


# -----
# IPv6 で、TCP, UDP の接続を受け付けることはない（ただのブリッジとなったため）
# SSH等は、IPv4 で受け付ける
ip6tables -A Lc_INPUT -j Lc_INPUT_LOG
# ip6tables -A Lc_INPUT -j ACCEPT
