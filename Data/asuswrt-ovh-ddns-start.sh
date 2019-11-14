#!/bin/sh

###
# Based on 
# https://github.com/RMerl/asuswrt-merlin/wiki/Custom-DDNS#google-domains
# https://github.com/RMerl/asuswrt-merlin/wiki/Custom-DDNS#bind9-ddns-using-nsupdate
#
# Forked from
# https://gist.github.com/atais/9ea6595072096ab8077f619bd3648da8
###

set -u

U=user
P=password
H=domain

# args: username password hostname ip
ovh_dns_update() {
  CMD=$(curl -s -u $1:$2 "https://www.ovh.com/nic/update?system=dyndns&hostname=$3&myip=$4")
  logger "ovh-ddns-updated: $CMD"
  case "$CMD" in
    good*|nochg*) /sbin/ddns_custom_updated 1 ;;
    *) /sbin/ddns_custom_updated 0 ;;
  esac
}

### When double NATed behind ISP's router this line gets IP from outside, otherwise, comment out next line.
IP=$(wget -O - -q http://myip.dnsomatic.com/)
# last parameter is IP, use $IP
ovh_dns_update $U $P $H $IP

exit 0