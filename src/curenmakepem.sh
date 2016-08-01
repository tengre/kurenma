#!/bin/bash
#
# $Id: curenmakepem.sh 19 2016-08-01 17:29:07+04:00 toor $
#
_bashlyk=kurenma . bashlyk
#
#
#
udfMain() {

	udfThrowOnCommandNotFound echo chmod mkdir openssl touch wg

	local conf confRules confTemplate path pathCrt pathKey s C ST L O OU ST EA
#
	path=/etc/kurenma/ssl
	pathCrt=${path}/public
	pathKey=${path}/private
	conf=${path}/kurenma.ssl
	confRules=dn.kurenma.ini
	confTemplate=${path}/openssl.cnf.template
#
	mkdir -p ${path}/{public,private,certs,newcerts,crl}
	chmod 0710 $pathKey

	[[ -f $confTemplate ]] && cp -fv $confTemplate $conf

	echo $(date "+%s") > ${path}/serial

	rm -f ${path}/index.txt
	touch ${path}/index.txt
#
	udfIni $confRules ':C;ST;L;O;OU;ST;EA'
#
	: ${C:=XX}
	: ${ST:=State}
	: ${L:=Locality}
	: ${O:=Organizational}
	: ${OU:=OrganizationalUnit}
	: ${CN:=CommonName}
	: ${EA:=email@address}

	for s in C ST L O OU ST EA; do

		sed -i -r -e "s/%${s}%/${!s}/ig" $conf

	done
#
	openssl req -nodes -new -x509 -keyout ${pathKey}/cakey.pem -out ${pathCrt}/cacert.pem -days 3650 -config $conf -verbose
	openssl dhparam -out ${pathCrt}/dh1024.pem 1024
#
	wg genkey | tee ${pathKey}/private.wg.key | wg pubkey > ${pathCrt}/public.wg.key
#
	chmod 0600 ${pathKey}/*

}
#
#
#
udfMain
#
