#!/bin/bash
#
# $Id: ssl-server-openssl.sh 114 2016-10-21 16:12:24+04:00 toor $"
#
#_bashlyk=kurenma _bashlyk_log=nouse . bashlyk
_bashlyk=kurenma . bashlyk
#
#
#
#
udmResetCounters() {

	bRevoked=0
	cn=''
	tsStart=0
	tsWait=60

}
#
udmCloseConnection() {

	udfDebug 3 "client $cn connection closed"

	udmResetCounters

	echo "connection down"
	sleep 1
	echo "q"

}
#
udmRevoked() {

	udfDebug 3 "client $cn cert revoked"
	echo "client cert revoked"

	udmCloseConnection

}
#
udmLimitConnectionTime() {

	udfIsNumber $1 || eval $( udfOnError return InvalidArgument "$1 - number expected" )
	udfIsNumber $tsStart || eval $( udfOnError return InvalidArgument "$tsStart - number expected" )
	(( tsStart > 0 )) || return 0
	[[ -n "$cn" ]] || eval $( udfOnError return EmptyArgument "cn" )

	local i=$(( $(date "+%s") - $tsStart ))

	(( i > 16 )) && udfDebug 3 "client $cn connection time is ${i}sec"

	if (( $i > $1 )); then

		udfDebug 3 "client $cn connection down by timeout ${i}sec"
		echo "client $cn connection down by timeout"

		udmCloseConnection

	fi

}
#
udfWaitRequest() {

	local bRevoked=0 cn i s tsStart=0 tsWait=60 rc

	while true; do

		read -t $tsWait s
		rc=$?

		#udfDebug 3 "rc=$rc : $s"

		if   (( rc > 128 )); then

			(( tsStart == 0 )) && udfDebug 3 "wait ${tsWait}sec"
			(( bRevoked > 0 )) && udmRevoked

		elif (( rc > 0 )); then

			udfDebug 3 "input closed"
			break

		elif [[ $s =~ ^signalStop$ ]]; then

			udfDebug 3 "SSL server down"

			sleep 0.2
			echo Q
			sleep 0.2
			break

		elif [[ $s =~ ^verify.*revoked.* ]]; then

			udfDebug 3 "warn: $cn revoked certificate"
			bRevoked=1
			tsWait=2

		elif [[ $s =~ depth=0.*CN.* ]]; then

			s="${s##*, CN = }"
			s="${s%,*}"

			[[ "$s" == "$cn" ]] && continue || cn=$s

			udfDebug 3 "client $cn connection start"

			tsStart=$(date "+%s")
			tsWait=4

		elif [[ $s =~ client-data.* ]]; then

			if (( bRevoked > 0 )); then

				udfDebug 3 "client data ignored"

			else

				udfDebug 3 "client data:${s##*client-data}"
				udfHandleRequest $cn ${s##*client-data}
				sleep 1.1
				udmCloseConnection

			fi


		elif [[ $s =~ ^(depth|verify|CIPHER|ERROR|CONNECTION|ACCEPT|subject|issuer) ]]; then

			udfDebug 3 "log $s"

		fi

		udmLimitConnectionTime 32

	done

}
#
udfHandleRequest() {

	udfThrowOnEmptyOrMissingArgument "$1" "$2"
	udfThrowOnEmptyVariable ipClient ipServer dev pathDat pathIni tsKeepalive tsPeerTimeout

	local aCIDR cnClient fn fnLeased i ip peer s

	cnClient=$1
	peer=$2

	fnLeased=${pathDat}/${cnServer}.${dev}.leased

	udfDebug 3 && \
		printf -- "\nremote peer info:\n\tClient Common Name\t- %s\n\tPublic key for %s\t- %s\n" \
			"$cnClient" "$dev" "${peer:0:10}<skipped>" >&2

	if [[ $(wg show $dev | grep peer | wc -l) -ge 253 ]]; then

		wg set $dev peer $(wg show $dev latest-handshakes | sort -k 2 -b -n | head -n 1 | cut -f 1) remove

	fi

	for s in $( wg show $dev latest-handshakes | tr '\t' ':' | xargs ); do

		if udfIsNumber ${s##*:}; then

			#ignore too low timestamps
			(( ${s##*:} < 1800 )) && continue

			i=$(( $(date +%s) - ${s##*:} ))

			if (( i >= tsPeerTimeout )); then

				wg set $dev peer ${s%%:*} remove
				udfDebug 2 "peer ${s:0:10}<skipped> is removed due to inactivity over an ${i}s .. $?"

			fi

		else

			eval $( udfOnError warn InvalidArgument "${s##*:}" )

		fi

	done

	if [[ "$ipClient" == "commonname" ]]; then

		ipClient=$( udfGetValidIPsOnly $cnClient )
		udfDebug 5 "Leased IP by Common Name to $cnClient - $ipClient"

	fi

	if [[ -z "$ipClient" || $ipClient == "dynamic" ]]; then

		[[ -f $fnLeased ]] || touch $fnLeased

		ipClient=$( grep -P "^${cnClient}:\S+$" $fnLeased | tail -n 1 | cut -f 2 -d':' | xargs )
		ipClient=$( udfGetValidIPsOnly $ipClient )

	fi

	if [[ -z "$ipClient" ]]; then

		s="$( wg show $dev allowed-ips )"

		for ((i=${ipServer##*.}; i<=254; i++)); do

			ip="${ipServer%.*}.$i";

			if [[ $s =~ ${ip}/32 ]]; then

				continue

			else

				ipClient=$( udfGetValidIPsOnly $ip )
				break

			fi

		done

	fi

	if [[ -z "$ipClient" ]]; then

		echo "not allocated IP to the client"
		eval $( udfOnError retecho EmptyOrMissingArgument "not allocated IP to the client" )

	fi

	aCIDR=$( udfGetValidCIDR ${ipClient}/32 ${ipsAllowed//[;,]/} )

	udfDebug 5 "allowed ips: $aCIDR"

	udfMakeTemp fn
	if wg set $dev peer "$peer" allowed-ips "${aCIDR// /,}" persistent-keepalive $tsKeepalive 2>$fn; then

		echo "OK:$( wg show $dev private-key | wg pubkey ):$( wg show $dev listen-port ):${ipClient}:${ipServer}"

		for s in $( wg show $dev peers ); do

			grep ":${s:0:10}$" $fnLeased

		done > $fn
		mv -f $fn $fnLeased
		echo "${cnClient}:${ipClient}:$(date +%s):${peer:0:10}" >> $fnLeased

	else

		echo "Error $(< $fn) $?"

	fi

	for s in $( wg show $dev allowed-ips | grep none | cut -f 1 | xargs ); do

		wg set $dev peer $s remove
		udfDebug 3 "${dev}: peer ${s:0:10}<skipped> is removed as unused .. $?"

	done

	udfDebug 1 "server configuration updated."
	udfDebug 5 && udfShowPeerInfo >&2

	wg showconf $dev > ${pathIni}/${cnServer}.${dev}.conf
	chmod 0600 ${pathIni}/${cnServer}.${dev}.conf

}
#
udfSetupTunnel() {

	udfThrowOnEmptyVariable dev ipServer port

	udfDebug 3 "Init WireGuard device $dev"

	try-every-line

		ip link del dev $dev 2>/dev/null || true
		ip link add dev $dev type wireguard
		ip address add ${ipServer}/24 dev $dev
		wg set $dev private-key <(wg genkey) listen-port $port
		ip link set up dev $dev

	catch-every-line

	udfDebug 3 "init new server pub key: $( wg show $dev private-key | wg pubkey | head -c 10 )<skipped>"

	return 0

}
#
udfService() {

	DEBUGLEVEL=3

	[[ $UID == 0 ]] || eval $( udfOnError throw NotPermitted "You must be root to run this." )

	udfThrowOnCommandNotFound cut kill ps sort
	udfThrowOnEmptyVariable cnServer dev ipServer pathCA pathCrt pathKey port portAuth

	local cmdSSL fn fnDH fnKey fnCrt

	if [[ -z "$( wg | grep $dev )" || -z "$( ip addr show $dev | grep $ipServer )" ]]; then

		udfSetupTunnel

	fi

	fnDH=${pathCrt}/dh2048.pem
	fnCrt=${pathCrt}/${cnServer}.crt
	fnKey=${pathKey}/${cnServer}.key
	cmdSSL="openssl s_server -cert $fnCrt -key $fnKey -accept $portAuth -CApath $pathCA -Verify 2 -crl_check_all -dhparam $fnDH"
	udfStopProcess "$cmdSSL"

	while true; do

		udfDebug 3 "Daemon for WireGuard clients (re)started.."

		udfMakeTemp fn type=pipe

		export _kurenma_control_channel=$fn
		udfWaitRequest < $fn | $cmdSSL > $fn 2>&1 &
		udfAddPid2Clean $!
		wait $!
		rm -f $fn

		udfWaitSignal 0.2 || break


	done

	udfStopProcess "$cmdSSL"

}
#
#
#
