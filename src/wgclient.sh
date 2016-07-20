#!/bin/bash
#
# $Id: wgclient.sh 6 2016-07-21 02:03:06+04:00 toor $
#
_bashlyk=saklaw-shelter . bashlyk
#
#
#

udfMain() {

	DEBUGLEVEL=4

	local a dev fn fnKey fnTmp fnRemotePub fnLocalPub fnLocalKey host i ini ipLocal iSerial path pathPri pathPub port encrypt s

	#path=/etc/saklaw-shelter
	path=/etc/wg
	ini=${path}/client.wg.ini
	pathPub=${path}/ssl/public
	pathPri=${path}/ssl/private

	udfThrowOnCommandNotFound echo ip grep knock nping openssl ping printf sed tee wg

	[[ $UID == 0 ]] || eval $( udfOnError throw  iErrorNotPermitted "You must be root to run this." )

	udfMakeTemp fnKey
	udfMakeTemp fnTmp

	udfIni $ini ':dev;host;port ssl:encrypt;decrypt'

	: ${dev:=wg0}
	: ${i:=128}

	udfDebug 2 "configuration:" && udfShowVariable dev host port encrypt decrypt
	udfThrowOnEmptyVariable dev host port encrypt decrypt

	fnRemotePub=$pathPub/$encrypt
	fnLocalPub=$pathPub/${decrypt:0:-4}.crt
	fnLocalKey=$pathPri/$decrypt

	if [[ -f $fnLocalPub && -f $fnLocalKey  && -f $fnRemotePub ]]; then

		iSerial=$( grep -Po "Serial Number: \d+ .*" $fnLocalPub | cut -f 3 -d' ' )
		udfDebug 3 && printf "client auth info:\n\tremote public key\t- %s\n\tlocal private key\t- %s\n\tlocal serial No.\t- %s\n" "$fnRemotePub" "$fnLocalKey" "$iSerial"

	else

		eval $( udfOnError throw iErrorNoSuchFileOrDir "$fnLocalPub and/or $fnLocalKey and/or $fnRemotePub" )

	fi

	## TODO send knocks and wait for destination port availibity ( nping )
	udfDebug 2 "check server availibity:"
	while true; do

		if echo "${i}%8" | bc | grep '^0$' >/dev/null; then

			knock $host 22025 23501 37565 && echo -n "!"

		fi
		sleep 1

		nc -w 8 -z ${host} ${port} 2>/dev/null && break
		echo -n "."
		i=$((i-1))
		(( $i > 0 )) || eval $( udfOnError throw iErrorNotPermitted "${host}:${port}" )

	done
	udfDebug 2 "ok."
	sleep 4

	s="$( wg genkey | tee $fnKey | wg pubkey | tee $fnTmp | udfEcho - $iSerial | openssl smime -encrypt -aes256 -outform PEM $fnRemotePub | nc -w 64 -i 16 $host $port | openssl smime -decrypt -inform PEM -inkey $fnLocalKey | tr -d '\r' )"

	udfDebug 4 && printf "\nclient wirequard keys:\n\tprivate\t- %s\n\tpublic\t- %s\n\n" "$(< $fnKey)" "$(< $fnTmp)"

	udfDebug 3 "server answer: $s"

	[[ $s =~ ^OK ]] || eval $( udfOnError throw iErrorNotValidArgument "bad answer from ${host}:${port} $s" )


	a=( ${s//:/ } )

	ip link del dev $dev 2>/dev/null || true
	ip link add dev $dev type wireguard
	wg set $dev private-key $fnKey peer "${a[1]}" allowed-ips 0.0.0.0/0 endpoint "${host}:${a[2]}"
	ip address add "${a[3]}"/24 dev $dev
	ip link set up dev $dev

	ping -t 1 -c 3 -q ${a[4]} >/dev/null 2>&1

	eval set -- $(_ sArg)

	if [[ "$1" == "default-route" ]]; then

		host="$(wg show $dev endpoints | sed -n 's/.*\t\(.*\):.*/\1/p')"
		echo "host for route to wg = $host"
		echo "route info for ${host}:"
		ip route get $host
		host="$( ip route get $host | sed '/ via [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/{s/^\(.* via [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/}' | head -n 1 )"
		echo "new route $host"
		ip route add $host 2>/dev/null || true
		ip route add 0/1 dev $dev
		ip route add 128/1 dev $dev

	fi

	udfDebug 1 "client configuration done."

	udfDebug 3 && {

		printf "\n\nWireguard interface %s info:\n-----------------------------\n\n" "$dev"
		wg

		printf "\n\nWireguard interface %s configuration:\n--------------------------------------\n\n" "$dev"
		wg showconf $dev

		printf "\n----\n"

	} >&2

	wg showconf $dev > ${path}/${decrypt:0:-4}_${encrypt:0:-4}.${dev}.conf
	chmod 0600 ${path}/${decrypt:0:-4}_${encrypt:0:-4}.${dev}.conf

}
#
#
#
udfMain
#
