##
## $Id: Makefile.am 39 2016-08-25 02:36:10+04:00 toor $
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

install-data-hook:
	$(shell) ln -sf /lib/systemd/system/${PACKAGE}.service /etc/systemd/system/${PACKAGE}.service && systemctl daemon-reload || true
