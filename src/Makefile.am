##
## $Id: Makefile.am 35 2016-08-16 14:56:36+04:00 toor $
##
#
AUTOMAKE_OPTIONS	= -Wno-portability
#
PACKAGE			= kurenma
ETC			= /etc
bin_SCRIPTS		= update-firehol gen-ssl-kurenma kurenmac
sbin_SCRIPTS		= kurenmas
systemddir		= /lib/systemd/system
systemd_DATA		= ${PACKAGE}.service
sysconfdir		= ${ETC}/${PACKAGE}
sysconf_DATA		= ipslist.ini client.${PACKAGE}.ini.example server.${PACKAGE}.ini.example dn.${PACKAGE}.ini
syslibdir		= /usr/share/${PACKAGE}
syslib_DATA		= knockd.conf.example openssl.cnf.template
DESTDIR			=

all:
	$(shell) ln -sf /lib/systemd/system/${PACKAGE}.service /etc/systemd/system/${PACKAGE}.service && systemctl daemon-reload
