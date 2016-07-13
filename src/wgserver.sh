#!/bin/bash
#
# $Id: wgserver.sh 4 2016-07-14 02:10:56+04:00 toor $
#
_bashlyk=saklaw-shelter . bashlyk
#
#
#
udfMain() {

	DEBUGLEVEL=1

	[[ $UID == 0 ]] || eval $( udfOnError throw iErrorNotPermitted "You must be root to run this." )

	local dev fn fnLocalKey fnRemoteCrt fnTmp ini ip ipLocal ipRemote keyPeer path pathPri pathPub timeKeepalive s

	udfThrowOnCommandNotFound cut echo grep ip nc openssl sort wg

	udfExitIfAlreadyStarted

	#path=/etc/saklaw-shelter
	path=/etc/wg
	pathPub=${path}/ssl/public
	pathPri=${path}/ssl/private
	ini=${path}/server.wg.ini

	udfIni $ini ':dev;port;portAuth;ipLocal;keepalive ssl:OU'

	: ${dev:=wg0}
	: ${ipLocal:=10.10.10.1}
	: ${port:=12912}
	: ${portAuth:=42912}
	udfIsNumber $keepalive && [[ $keepalive -gt 10 && $keepalive -lt 3600 ]] || keepalive=333

	udfDebug 1 && udfShowVariable dev ipLocal port portAuth OU
	udfThrowOnEmptyVariable OU

#	if [[ -z "$( wg | grep $dev )" ]]; then

		ip link del dev $dev 2>/dev/null
		ip link add dev $dev type wireguard
		ip address add ${ipLocal}/24 dev $dev
		wg set $dev private-key <(wg genkey) listen-port $port
		ip link set up dev $dev

#	fi

	fnLocalKey=${pathPri}/${OU}.key

	[[ -n $fnLocalKey && -f $fnLocalKey ]] || eval $(udfOnError exitecho iErrorNoSuchFileOrDir "$fnLocalKey")

	udfMakeTemp fnTmp

	nc -l $portAuth | openssl smime -decrypt -inform PEM -inkey $fnLocalKey | tr -d '\r' > $fnTmp

	[[ $(wc -l < $fnTmp) == 3 ]] || eval $( udfOnError throw iErrorNotValidArgument "client data not valid $(<$fnTmp)" )

	keyPeer="$( tail -n +3 $fnTmp )"
	s=$( head -n 1 $fnTmp )

	rm -f $fnTmp

	for fn in $(ls $pathPub); do

		if [[ -f $pathPub/$fn && $fn =~ .crt ]]; then

			iSerial="$( grep -Po "Serial Number: \d+ .*" $pathPub/$fn | cut -f 3 -d' ' )"

		else

			continue

		fi

		[[ $s == $iSerial ]] || continue

		fnRemoteCrt=${pathPub}/$fn
		break

	done

	udfDebug 1 && printf "\nremote peer info:\n\tSerial No.\t- %s(%s)\n\twg public key\t- %s\n" "$s" "${fnRemoteCrt##*/}" "$keyPeer"

	if [[ $(wg show $dev | grep peer | wc -l) -ge 253 ]]; then

		wg set $dev peer $(wg show $dev latest-handshakes | sort -k 2 -b -n | head -n 1 | cut -f 1) remove

	fi

	ipRemote=$( s="$( wg show $dev allowed-ips )"; for ((i=2; i<=254; i++)); do ip="${ipLocal%.*}.$i"; [[ $s != *${ip}/32* ]] && echo $ip && break; done )

	if wg set $dev peer "$keyPeer" allowed-ips "${ipRemote}/32" persistent-keepalive $keepalive; then

		echo "OK:$( wg show $dev private-key | wg pubkey ):$( wg show $dev listen-port ):${ipRemote}:${ipLocal}"

	else

		echo ERROR

	fi | openssl smime -encrypt -outform PEM $fnRemoteCrt | nc -l $portAuth

	echo "server configuration completed"

	printf "\n\nWireguard interface %s info:\n-----------------------------\n\n" "$dev"
	wg
	printf "\n\nWireguard interface %s configuration:\n--------------------------------------\n\n" "$dev"

	wg showconf $dev | tee $path/${OU}.${dev}.conf

	printf "\n----\n"

	chmod 0600 ${path}/${OU}.${dev}.conf

}
#
#
#
udfMain
#
