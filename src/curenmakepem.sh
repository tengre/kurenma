#!/bin/bash
#
# $Id: curenmakepem.sh 20 2016-08-02 15:04:23+04:00 toor $
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

	udfThrowOnCommandNotFound echo chmod mkdir openssl rm sed touch wg

	local conf confDN fnTemplate path pathCnf pathCrt pathKey s csv='C;ST;L;O;OU;CN;EA'
	eval $(_defLocal $csv)
#
	path=/etc/kurenma/ssl
	pathCrt=${path}/public
	pathKey=${path}/private
	pathCnf=${path}/configs
	conf=${pathCnf}/kurenma.ssl
	confDN=${path}/dn.kurenma.ini
	fnTemplate=${path}/openssl.cnf.template
#
	mkdir -p ${path}/{public,private,configs,certs,newcerts,crl,csr}
	chmod 0710 $pathKey

	[[ -f $fnTemplate ]] && cp -fv $fnTemplate $conf

	echo $(date "+%s") > ${path}/serial

	rm -f ${path}/index.txt
	touch ${path}/index.txt
#
	udfIni $confDN ":${csv}"
#
	: ${C:=XX}
	: ${ST:=State}
	: ${L:=Locality}
	: ${O:=Organizational}
	: ${OU:=OrganizationalUnit}
	: ${CN:=CommonName}
	: ${EA:=email@domain.name}

	for s in ${csv//[;,]/ }; do

		sed -i -r -e "s/%${s}%/${!s}/ig" $conf

	done
#
	openssl req -nodes -new -x509 -keyout ${pathKey}/cakey.pem -out ${pathCrt}/cacert.pem -days 3650 -config $conf -verbose
	#openssl dhparam -out ${pathCrt}/dh2048.pem 2048
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
