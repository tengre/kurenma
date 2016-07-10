#!/bin/bash
#
# $Id: wgmakepem.sh 1 2016-07-10 18:56:46+04:00 toor $
#
_bashlyk=openssl . bashlyk
#
#
#
udfMain() {

	udfThrowOnCommandNotFound echo chmod mkdir openssl touch wg

	local path pathSSL conf confTemplate

	path=/etc/wg/ssl
	pathPub=${path}/public
	pathPrv=${path}/private
	conf=${path}/wg.ssl
	confTemplate=${path}/openssl.cnf.template
#
	mkdir -p ${path}/{public,private,certs,newcerts,crl}
	chmod 0710 $pathPrv

	[[ -f $confTemplate ]] && cp -fv $confTemplate $conf

	echo $(date "+%s") > ${path}/serial

	rm -fv ${path}/index.txt
	touch ${path}/index.txt
# 
	openssl req -nodes -new -x509 -keyout ${pathPrv}/cakey.pem -out ${pathPub}/cacert.pem -days 3650 -config $conf -verbose
	openssl dhparam -out ${pathPub}/dh1024.pem 1024
#
	wg genkey | tee ${pathPrv}/private.wg.key | wg pubkey > ${pathPub}/public.wg.key
#
	chmod 0600 ${pathPrv}/*

}
#
#
#
udfMain
#
