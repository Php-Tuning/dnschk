#!/usr/bin/env bash

function checkDependencies() {
	test "$(whereis dig | grep "\/" -c)" -gt 0 && return
	echo "Error: the command dig needs to be available. Please install it first"
	echo "in most distributions it's in the dnsutils package"
	exit
}

function checkArgs() {
	[[ "$#" != "1" || "$1" = "-h" || "$1" = "--help" ]] \
		&& echo "usage: ./dnschk.sh domainname.de" && exit
}

function digResult () {
	local domainGet="$1"
	local dnsServer="$2"
	local result=""
	if [ "${dnsServer}" = "" ] ; then
		echo -n "normal:   "
		result="$(dig "${domainGet}" | grep -e "[0-9]\sIN\s[A\|CNAME]")"
	else
		echo -n "@${dnsServer}: "
		result="$(dig "${domainGet}" "@${dnsServer}" | grep -e "[0-9]\sIN\s[A\|CNAME]")"
	fi
	test "${result}" = "" && result="no Result"
	echo "${result}"
}

function main() {
	checkDependencies
	checkArgs "$@"

	local domain="$1"
	local prefix=""
	for prefix in "" "www." ; do
		echo "=== query domain ${prefix}${domain} ==="
		#system dns, cloudflare (1.1.1.1), google (8.8.8.8) and Quad9 (9.9.9.9)
		for dns in "" "1.1.1.1" "8.8.8.8" "9.9.9.9" ; do
			digResult "${prefix}${domain}" "${dns}"
		done
	done
}

###---

main "$@"
