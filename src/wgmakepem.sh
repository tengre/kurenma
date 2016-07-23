#!/bin/bash
#
# $Id: wgmakepem.sh 10 2016-07-25 01:34:53+04:00 toor $
#
_bashlyk=kurenma . bashlyk
#
#
#
udfMain() {

	udfThrowOnCommandNotFound echo chmod mkdir openssl touch wg

	local path pathCrt pathKey conf confTemplate

	path=/etc/kurenma/ssl
	pathCrt=${path}/public
	pathKey=${path}/private
	conf=${path}/kurenma.ssl
	confTemplate=${path}/openssl.cnf.template
#
	mkdir -p ${path}/{public,private,certs,newcerts,crl}
	chmod 0710 $pathKey

	[[ -f $confTemplate ]] && cp -fv $confTemplate $conf

	echo $(date "+%s") > ${path}/serial

	rm -fv ${path}/index.txt
	touch ${path}/index.txt
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
