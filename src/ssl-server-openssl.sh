#!/bin/bash
#
# $Id: ssl-server-openssl.sh 112 2016-10-20 17:24:56+04:00 toor $"
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

	local bRevoked=0 cn i s tsStart=0 tsWait=60

	while true; do

		if ! read -t $tsWait s; then

			(( tsStart == 0 )) && udfDebug 3 "."
			(( bRevoked > 0 )) && udmRevoked

		elif [[ $s =~ ^verify.*revoked.* ]]; then

			bRevoked=1
			tsWait=2

		elif [[ $s =~ depth=0.*CN.* ]]; then

			cn="${s##*, CN = }"
			cn=${cn%,*}

			udfDebug 3 "client $cn connection start"

			tsStart=$(date "+%s")
			tsWait=4

		elif [[ $s =~ client-data.* ]]; then

			udfDebug 3 "client data:${s##*client-data}"

			udmCloseConnection

		elif [[ $s =~ ^(-----|depth|verify|CIPHER|ERROR|CONNECTION|ACCEPT|subject|issuer) ]]; then

			udfDebug 3 "log $s"

		fi

		udmLimitConnectionTime 48

	done

}
#
udfMain() {

	DEBUGLEVEL=3

	[[ $UID == 0 ]] || eval $( udfOnError throw NotPermitted "You must be root to run this." )

	eval set -- $( _ sArg )

	udfThrowOnEmptyOrMissingArgument $@

	local cn fn fnDH fnKey fnCert path pathCert

	cn=$1
	path=/etc/kurenma/ssl
	pathCert=${path}/certs
	fnDH=${path}/public/dh2048.pem
	fnCert=${path}/public/${1}.crt
	fnKey=${path}/private/${1}.key

	udfDebug 3 "openssl s_server -cert $fnCert -key $fnKey -accept 443 -CApath $pathCert -Verify 2 -crl_check_all -dhparam $fnDH"

	udfMakeTemp fn type=pipe

	udfWaitRequest < $fn | openssl s_server -cert $fnCert -key $fnKey -accept 443 -CApath $pathCert -Verify 2 -crl_check_all -dhparam $fnDH > $fn 2>&1

}
#
#
#
udfMain
#
