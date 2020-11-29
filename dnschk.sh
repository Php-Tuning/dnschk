#!/bin/bash

if [ "$(whereis dig | grep "\/" -c)" = "0" ] ; then
	echo "Error: the command dig needs to be available. Please install it first"
	echo "in most distributions it's in the dnsutils package"
	exit
fi
#defaults to system dns, cloudflare (1.1.1.1), google (8.8.8.8) and Quad9 (9.9.9.9)
dnsservers=( "" "1.1.1.1" "8.8.8.8" "9.9.9.9" )
prefixes=( "" "www." )

if [[ "$@" = "" || "$@" = "-h" || "$@" = "--help" ]] ; then
	echo "usage: ./dnschk.sh domainname.de"
	exit
fi

domain="$@"

function digres () {
	if [ "${dns}" = "" ] ; then
		echo -n "normal:   "
	else
		echo -n "${dns}: "
	fi
	result="`dig \"${dget}\" ${dns} | grep -e \"[0-9]\sIN\s[A\|CNAME]\"`"
	if [ "$result" = "" ] ; then
		echo "no Result"
	else
		echo "$result"
	fi
}

###---

for prefix in "${prefixes[@]}" ; do
	dget="${prefix}${domain}"
	echo "=== query domain ${dget} ==="
	for dns in "${dnsservers[@]}" ; do
		if [ "$dns" != "" ] ; then
			dns="@${dns}"
		fi
		digres
	done
done
