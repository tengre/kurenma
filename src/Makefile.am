##
## $Id: Makefile.am 34 2016-08-16 14:53:44+04:00 toor $
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
sysconf_DATA		= ipslist.ini client.${PACKAGE}.ini server.${PACKAGE}.ini dn.${PACKAGE}.ini
syslibdir		= /usr/share/${PACKAGE}
syslib_DATA		= knockd.conf.example openssl.cnf.template
DESTDIR			=

all:
	$(shell) ln -sf /lib/systemd/system/${PACKAGE}.service /etc/systemd/system/${PACKAGE}.service && systemctl daemon-reload
