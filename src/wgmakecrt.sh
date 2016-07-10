#!/bin/bash
#
# $Id: wgmakecrt.sh 1 2016-07-10 18:56:46+04:00 toor $
#
_bashlyk=openssl . bashlyk
#
#
#
udfMain() {

	[[ -n "$1" ]] || eval $( udfOnError throw iErrorEmptyOrMissing )

	udfThrowOnCommandNotFound chmod openssl

	local conf path pathPrv pathPub

	path=/etc/wg/ssl
	pathPrv=${path}/private
	pathPub=${path}/public
	conf=${path}/wg.ssl
#
	openssl req -new -nodes -keyout ${pathPrv}/${1}.key -out ${path}/${1}.csr -config $conf -verbose
	openssl ca  -in ${path}/${1}.csr -out ${pathPub}/${1}.crt -config $conf -verbose
#
chmod 0600 ${pathPrv}/${1}.key
#
