##
## $Id: Makefile.am 46 2016-09-05 17:19:00+04:00 toor $
##
#
AUTOMAKE_OPTIONS	= -Wno-portability
#
PACKAGE			= kurenma
ETC			= /etc
bin_SCRIPTS		= update-firehol gen-ssl-kurenma
sbin_SCRIPTS		= kurenma kurenmas kurenmac
systemddir		= /lib/systemd/system
systemd_DATA		= ${PACKAGE}.service
sysconfdir		= ${ETC}/${PACKAGE}
sysconf_DATA		= ipslist.ini ${PACKAGE}.ini.example dn.${PACKAGE}.ini
syslibdir		= /usr/share/${PACKAGE}
syslib_DATA		= knockd.conf.example openssl.cnf.template
DESTDIR			=

install-data-hook:
	$(shell) ln -sf /lib/systemd/system/${PACKAGE}.service /etc/systemd/system/${PACKAGE}.service && systemctl daemon-reload || true
