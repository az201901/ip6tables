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
# ff02::2 に向けての RS を FW する意義はない
ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type router-solicitation -j DROP
ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type neighbour-advertisement -j ACCEPT
ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type neighbour-solicitation -j ACCEPT
ip6tables -A W_FW_icmpv6 -p icmpv6 --icmpv6-type redirect -j ACCEPT

ip6tables -A W_FW_icmpv6 -j NFLOG --nflog-group 0 --nflog-prefix 'Drp_W_FW_icmpv6: '
ip6tables -A W_FW_icmpv6 -j DROP
# ip6tables -A W_FW_icmpv6 -j ACCEPT


# ---------------------------
ip6tables -N W_FW
ip6tables -A W_FW -p icmpv6 -j W_FW_icmpv6

# DHCPv6（udp による host アドレス以外の情報取得）
# 547 に向けて発信すると、546 に返ってくる
ip6tables -A W_FW -p udp --dport 546 -s $zone_local -j ACCEPT


# ---------------------------
# 未接続、RST で来るのは、ONU でのチェックをすり抜けた ACK=0 のもの
#（CDN や LB からの可能性もあるが、広告関連のものが多い、、）
ip6tables -A W_FW -p tcp --tcp-flags RST RST -j DROP


ip6tables -A W_FW -j W_FW_LOG
# ip6tables -A W_FW -j ACCEPT

