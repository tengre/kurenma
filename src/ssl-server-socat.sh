#!/bin/bash
#
# $Id: ssl-server-socat.sh 112 2016-10-20 17:24:56+04:00 toor $"
#
_bashlyk=kurenma _bashlyk_log=nouse . bashlyk
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

	udfWaitRequest < $fn | socat -d -d -d -d openssl-listen:443,cert=${fnCert},key=${fnKey},capath=${pathCert},dhparam=${fnDH} > $fn 2>&1

}
#
#
#
udfWaitRequest() {

    local s
    while read s; do

	if [[ $s =~ ^[0-9]+/[0-9]+/[0-9]+.[0-9]+:[0-9]+:[0-9]+.socat.*$ ]]; then

	    if [[ $s =~ subject:.*CN=.*$ ]]; then

		s=${s##*/CN=}
		s=${s%/*}

		cd /etc/kurenma/ssl

		openssl verify -crl_check -CApath certs public/${s}.crt || exit 1

	    fi

	else

	    echo "data $s"

	fi

    done

}
#
#
#
udfMain
#
