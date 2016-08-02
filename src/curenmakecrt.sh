#!/bin/bash
#
# $Id: curenmakecrt.sh 20 2016-08-02 12:55:59+04:00 toor $
#
_bashlyk=kurenma . bashlyk
#
#
#
_defLocal() {

	local s S

	for s in ${*//[;,]/ }; do

		udfIsValidVariable $s || eval $( udfOnError throw iErrorNonValidVariable "$s" )
		S+="$s "

	done

	echo "local ${S% *}"

}
#
udfMain() {

	eval set -- $( _ sArg )

	[[ -n "$1" ]] || eval $( udfOnError throw iErrorEmptyOrMissingArgument )

	udfThrowOnCommandNotFound chmod cp openssl sed

	local conf fnTemplate path pathCnf pathCrt pathCsr pathKey s csv='C;ST;L;O;OU;CN;EA'
	eval $(_defLocal $csv)

	path=/etc/kurenma/ssl
	pathCsr=${path}/csr
	pathCrt=${path}/public
	pathKey=${path}/private
	pathCnf=${path}/configs
	conf=${pathCnf}/${1}.kurenma.ssl
	confDN=${path}/dn.kurenma.ini
	fnTemplate=${path}/openssl.cnf.template
#
	for s in "$path" "$pathKey" "$pathCrt" "$pathCsr" "$pathCnf"; do

		[[ -d "$s" ]] || eval $( udfOnError throw iErrorNoSuchFileOrDir "$s" )

	done

	for s in "$confDN" "$fnTemplate"; do

		[[ -f $s ]] || eval $( udfOnError throw iErrorNoSuchFileOrDir "$s" )

	done

	cp -f $fnTemplate $conf

	udfIni $confDN ":${csv}"
#
	: ${C:=XX}
	: ${ST:=State}
	: ${L:=Locality}
	: ${O:=Organizational}
	: ${OU:=OrganizationalUnit}
	: ${EA:=postmaster@$1}

	OU=${1%%.*}
	CN=$1

	for s in ${csv//[;,]/ }; do

		sed -i -r -e "s/%${s}%/${!s}/ig" $conf

	done
#
	openssl req -new -nodes -keyout ${pathKey}/${1}.key -out ${pathCsr}/${1}.csr -config $conf -verbose
	openssl ca  -in ${pathCsr}/${1}.csr -out ${pathCrt}/${1}.crt -config $conf -verbose
#
	chmod 0600 ${pathKey}/${1}.key

}
#
#
#
udfMain
#
