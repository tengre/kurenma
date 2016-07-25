#!/bin/bash
#
# $Id: wgserver.sh 10 2016-07-25 01:34:53+04:00 toor $
#
_bashlyk=kurenma . bashlyk
#
#
#
udfMakeFifo() {

	[[ -n "$1" ]] || eval $( udfOnError iErrorEmptyOrMissingArgument )
	udfMakeTemp $1 path=/var/run
	rm -f ${!1}
	mkfifo ${!1}

}
#
udfWaitRequest() {

	local -r iMax=64
	local i=0 s csv
	#
	while read s; do

		udfDebug 5 "input: $s ${i}" >&2
		csv+="${s}:"
		i=$((i+1))

		if (( $i > $iMax )); then

			echo "Warn: too many lines received, abort .." >&2
			break

		fi

		[[ $s =~ ^-----END.PKCS7-----$ ]] && break

	done

	if [[ $csv =~ ^-----BEGIN.PKCS7-----.*-----END.PKCS7-----:$ ]]; then

		udfHandleRequest "$csv"

	else

		echo "unexpected.."

	fi
}
#
udfHandleRequest() {

	## TODO udfThrowOnEmptyArgument
	[[ -n "$1" ]] || eval $( udfOnError retecho iErrorEmptyOrMissingArgument )

	udfThrowOnEmptyVariable fnServerKey ipServer dev pathCrt keepalive

	local fn s keyPeer fnClientCrt cnClient ipClient IFS

	udfMakeTemp fn

	IFS=':'
	for s in $1; do

		echo $s

	done | openssl smime -decrypt -inform PEM -inkey $fnServerKey | tr -d '\r' > $fn
	IFS=$' \t\n'

	udfDebug 5 && {

		printf "\nreceived data:\n"
		cat $fn

	} >&2

	if [[ $( wc -l < $fn ) != 3 ]]; then

		echo "Error - unexpected format"
		eval $( udfOnError retwarn iErrorNotValidArgument "untrusted input data" )

	fi

	keyPeer="$( tail -n +3 $fn )"
	s=$( head -n 1 $fn )
	rm -f $fn

	for fn in $( ls $pathCrt ); do

		if [[ -f $pathCrt/$fn && $fn =~ .crt ]]; then

			cnClient="$( grep 'Subject:' $fnClientCrt | sed -re "s/.*CN=(.*)\/email.*/\1/" )"

		else

			continue

		fi

		[[ $s == $cnClient ]] || continue

		fnClientCrt=${pathCrt}/$fn
		break

	done

	if [[ -z "$fnClientCrt" ]]; then

		echo "Error - unexpected request"
		eval $( udfOnError retecho iErrorNotPermitted "client certificate not found" )

	fi

	udfDebug 4 && printf "\nremote peer info:\n\tSerial No.\t- %s(%s)\n\twg public key\t- %s\n" "$s" "${fnClientCrt##*/}" "$keyPeer" >&2

	if [[ $(wg show $dev | grep peer | wc -l) -ge 253 ]]; then

		wg set $dev peer $(wg show $dev latest-handshakes | sort -k 2 -b -n | head -n 1 | cut -f 1) remove

	fi

	ipClient=$( s="$( wg show $dev allowed-ips )"; for ((i=2; i<=254; i++)); do ip="${ipServer%.*}.$i"; [[ $s != *${ip}/32* ]] && echo $ip && break; done )

	udfMakeTemp fn
	if wg set $dev peer "$keyPeer" allowed-ips "${ipClient}/32" persistent-keepalive $keepalive 2>$fn; then

		echo "OK:$( wg show $dev private-key | wg pubkey ):$( wg show $dev listen-port ):${ipClient}:${ipServer}"

	else

		echo "Error $(< $fn) $?"

	fi | openssl smime -encrypt -outform PEM $fnClientCrt

	udfDebug 1 "server configuration updated" >&2

	udfDebug 3 && {

		printf "\n\nWireguard interface %s info:\n-----------------------------\n\n" "$dev"
		wg

		printf "\n\nWireguard interface %s configuration:\n--------------------------------------\n\n" "$dev"
		wg showconf $dev

		printf "\n----\n"

	} >&2

	wg showconf $dev > $path/${cnServer}.${dev}.conf
	chmod 0600 ${path}/${cnServer}.${dev}.conf

}
#
udfMain() {

	DEBUGLEVEL=4

	[[ $UID == 0 ]] || eval $( udfOnError throw iErrorNotPermitted "You must be root to run this." )

	local dev fn fnServerKey fnTmp ini ip ipServer ipClient keyPeer path pathKey pathCrt keepalive s

	udfThrowOnCommandNotFound cut echo grep ip kill nc openssl ps sort wg

	udfExitIfAlreadyStarted

	path=/etc/kurenma
	pathCrt=${path}/ssl/public
	pathKey=${path}/ssl/private
	ini=${path}/server.kurenma.ini

	udfIni $ini ':dev;port;portAuth;ipServer;keepalive ssl:cnServer'

	: ${dev:=wg0}
	: ${ipServer:=192.168.29.1}
	: ${port:=12912}
	: ${portAuth:=42912}
	udfIsNumber $keepalive && [[ $keepalive -gt 10 && $keepalive -lt 3600 ]] || keepalive=333

	udfDebug 2 && udfShowVariable dev ipServer port portAuth cnServer
	udfThrowOnEmptyVariable cnServer

	if [[ -z "$( wg | grep $dev )" || -z "$( ip addr show $dev | grep $ipServer )" ]]; then

		ip link del dev $dev 2>/dev/null
		ip link add dev $dev type wireguard
		ip address add ${ipServer}/24 dev $dev
		wg set $dev private-key <(wg genkey) listen-port $port
		ip link set up dev $dev

	fi

	fnServerKey=${pathKey}/${cnServer}.key

	[[ -n $fnServerKey && -f $fnServerKey ]] || eval $(udfOnError exitecho iErrorNoSuchFileOrDir "$fnServerKey")

	s=$( ps -C nc -o pid= -o args= | grep -w "$portAuth" | cut -f 1 -d' ' )
	[[ -n "$s" ]] && kill -9 $s

	udfMakeFifo fnTmp
	cat $fnTmp | udfWaitRequest | nc -l -k -v $portAuth > $fnTmp

}
#
#
#
udfMain
#
