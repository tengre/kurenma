##
## $Id: Makefile.am 23 2016-08-03 14:53:25+04:00 toor $
##
#
AUTOMAKE_OPTIONS	= -Wno-portability
#
PACKAGE			= kurenma
ETC			= /etc
bin_SCRIPTS		= update-firehol gen-ssl-kurenma kurenmac
sbin_SCRIPTS		= kurenmas
sysconfdir		= ${ETC}/${PACKAGE}
sysconf_DATA		= ipslist.ini client.${PACKAGE}.ini server.${PACKAGE}.ini dn.${PACKAGE}.ini
syslibdir		= /usr/share/${PACKAGE}
syslib_DATA		= knockd.conf.example openssl.cnf.template
DESTDIR			=
