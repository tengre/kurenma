#!/bin/bash
#
# $Id: curenmakecrt.sh 19 2016-08-01 17:13:52+04:00 toor $
#
_bashlyk=kurenma . bashlyk
#
#
#
udfMain() {

	eval set -- $( _ sArg )

	[[ -n "$1" ]] || eval $( udfOnError throw iErrorEmptyOrMissingArgument )

	udfThrowOnCommandNotFound chmod openssl

	local conf path pathKey pathCrt

	path=/etc/kurenma/ssl
	pathKey=${path}/private
	pathCrt=${path}/public
	conf=${path}/kurenma.ssl
#
	## TODO throw on not exist $conf $path{Crt,Key}
	## TODO require a filename as CN
	## TODO use preedit ssl file for use CN as default
#
	openssl req -new -nodes -keyout ${pathKey}/${1}.key -out ${path}/${1}.csr -config $conf -verbose
	openssl ca  -in ${path}/${1}.csr -out ${pathCrt}/${1}.crt -config $conf -verbose
#
	chmod 0600 ${pathKey}/${1}.key

}
#
#
#
udfMain
#
