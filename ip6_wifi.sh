#!/bin/bash

source 'ip6_wifi_h.sh'

# ===========================
ip6tables -F
ip6tables -X
ip6tables -Z

# ポリシーの設定
# ip6tables -P INPUT DROP
# ip6tables -P OUTPUT DROP
# ip6tables -P FORWARD DROP

ip6tables -P INPUT ACCEPT
ip6tables -P OUTPUT ACCEPT
ip6tables -P FORWARD ACCEPT


# ===========================
# loopbadk
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT


# ===========================
# 一度処理を許可したものは許可
ip6tables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A OUTPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A FORWARD -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

ip6tables -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
# udp、OUTPUT 通信確立は DNS の返答くらい？？
# ip6tables -A OUTPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A FORWARD -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT


# ===========================
bash 'ip6_wifi_W_INPUT.sh'
bash 'ip6_wifi_Cmn_OUT.sh'
bash 'ip6_wifi_W_FW.sh'

ip6tables -A INPUT -m physdev --physdev-in enp1s0 -j W_INPUT
# ip6tables -A OUTPUT -m physdev --physdev-out enp1s0 -j W_OUTPUT
ip6tables -A OUTPUT -j Cmn_OUT
ip6tables -A FORWARD -m physdev --physdev-in enp1s0 -j W_FW



echo '<< ip6 tables >> の設定が正しく処理されました'

