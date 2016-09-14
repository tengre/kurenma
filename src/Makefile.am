##
## $Id: Makefile.am 72 2016-09-14 16:11:15+04:00 toor $
##
#
AUTOMAKE_OPTIONS	= -Wno-portability
#
PACKAGE			= kurenma
ETC			= /etc
bin_SCRIPTS		= update-firehol gen-ssl-kurenma
sbin_SCRIPTS		= kurenmactl kurenmad
systemvdir		= ${ETC}/init.d
systemv_SCRIPTS		= ${PACKAGE}
systemddir		= /lib/systemd/system
systemd_DATA		= ${PACKAGE}.service
sysconfdir		= ${ETC}/${PACKAGE}
sysconf_DATA		= ipslist.ini ${PACKAGE}.ini.example dn.${PACKAGE}.ini
syslibdir		= /usr/share/${PACKAGE}
syslib_DATA		= knockd.conf.example openssl.cnf.template client.kurenma.src server.kurenma.src
DESTDIR			=

install-data-hook:
	$(shell) which systemctl || update-rc.d ${systemv_SCRIPTS} defaults || true
	$(shell) which systemctl && chmod -x ${systemvdir}/${systemv_SCRIPTS} && mv -v ${systemvdir}/${systemv_SCRIPTS} ${systemvdir}/${systemv_SCRIPTS}.disabled || true
	$(shell) which systemctl && systemctl enable ${PACKAGE} && systemctl daemon-reload || true

uninstall-hook:
	$(shell) which systemctl || update-rc.d -f ${systemv_SCRIPTS} remove || true
	$(shell) which systemctl && rm -f ${systemvdir}/${systemv_SCRIPTS}.disabled || true
	$(shell) which systemctl && systemctl disable ${PACKAGE} && systemctl daemon-reload || true

