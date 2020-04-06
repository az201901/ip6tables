#!/bin/bash

source 'ip6_wifi_h.sh'

# ---------------------------
# ログ用 チェーン
ip6tables -N W_INPUT_LOG
ip6tables -A W_INPUT_LOG -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_W_INPUT: '
ip6tables -A W_INPUT_LOG -j DROP
# ip6tables -A W_INPUT_LOG -j ACCEPT


# ---------------------------
# icmpv6 チェーン
ip6tables -N W_INPUT_icmpv6
ip6tables -A W_INPUT_icmpv6 ! -s $zone_local -j W_INPUT_LOG

ip6tables -A W_INPUT_icmpv6 -p icmpv6 --icmpv6-type echo-request -j ACCEPT
ip6tables -A W_INPUT_icmpv6 -p icmpv6 --icmpv6-type echo-reply -j ACCEPT
ip6tables -A W_INPUT_icmpv6 -p icmpv6 --icmpv6-type router-advertisement -j ACCEPT
# ip6tables -A W_INPUT_icmpv6 -p icmpv6 --icmpv6-type router-solicitation -j ACCEPT
ip6tables -A W_INPUT_icmpv6 -p icmpv6 --icmpv6-type neighbour-advertisement -j ACCEPT
ip6tables -A W_INPUT_icmpv6 -p icmpv6 --icmpv6-type neighbour-solicitation -j ACCEPT
ip6tables -A W_INPUT_icmpv6 -p icmpv6 --icmpv6-type redirect -j ACCEPT

ip6tables -A W_INPUT_icmpv6 -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_W_INPUT_icmpv6: '
ip6tables -A W_INPUT_icmpv6 -j DROP
# ip6tables -A W_INPUT_icmpv6 -j ACCEPT


# ---------------------------
ip6tables -N W_INPUT
ip6tables -A W_INPUT -p icmpv6 -j W_INPUT_icmpv6

# DHCPv6（udp による host アドレス以外の情報取得）
# 547 に向けて発信すると、546 に返ってくる
ip6tables -A W_INPUT -p udp --dport 546 -s $zone_local -j ACCEPT


# -----
# IPv6 で、TCP, UDP の接続を受け付けることはない（ただのブリッジとなったため）
# SSH等は、IPv4 で受け付ける
ip6tables -A W_INPUT -j W_INPUT_LOG
# ip6tables -A W_INPUT -j ACCEPT
