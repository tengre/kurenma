##
## $Id: Makefile.am 218 2018-08-10 10:28:21+04:00 yds $
##
#
AUTOMAKE_OPTIONS	= -Wno-portability
#
PACKAGE			= kurenma
ETC			= /etc
bin_SCRIPTS		= kurenma-firehol-update kurenma-ssl-gen kurenma-knockd-setup
sbin_SCRIPTS		= kurenmactl kurenmad
defaultdir		= ${ETC}/default
default_DATA		= .${defaultdir}/${PACKAGE}
logconfdir		= ${ETC}/logrotate.d
logconf_DATA		= .${logconfdir}/${PACKAGE}
systemvdir		= ${ETC}/init.d
systemv_SCRIPTS		= .${systemvdir}/${PACKAGE}
systemddir		= /lib/systemd/system
systemd_DATA		= ${PACKAGE}.service
sysconfdir		= ${ETC}/${PACKAGE}
sysconf_DATA		= ipslist.ini ${PACKAGE}.ini.example dn.${PACKAGE}.ini
syslibdir		= /usr/share/${PACKAGE}
syslib_DATA		= knockd.conf.example openssl.cnf.template client.kurenma.src server.kurenma.src ../VERSION
DESTDIR			=

$(systemv_SCRIPTS) : ${PACKAGE}.initd
	$(shell) mkdir -p .${systemvdir}
	$(shell) cp -fv $< $@

$(default_DATA) : ${PACKAGE}.default
	$(shell) mkdir -p .${defaultdir}
	$(shell) cp -fv $< $@

$(logconf_DATA) : ${PACKAGE}.logrotated
	$(shell) mkdir -p .${logconfdir}
	$(shell) cp -fv $< $@

install-data-hook:
	$(shell) test -d /run/systemd/system || update-rc.d ${systemv_SCRIPTS} defaults || true
	$(shell) test -d /run/systemd/system && chmod -x ${systemvdir}/${systemv_SCRIPTS} && mv -v ${systemvdir}/${systemv_SCRIPTS} ${systemvdir}/${systemv_SCRIPTS}.disabled-by-systemd || true
	$(shell) test -d /run/systemd/system && systemctl enable ${PACKAGE} && systemctl daemon-reload || true

uninstall-hook:
	$(shell) test -d /run/systemd/system || update-rc.d -f ${systemv_SCRIPTS} remove || true
	$(shell) test -d /run/systemd/system && rm -f ${systemvdir}/${systemv_SCRIPTS}.disabled-by-systemd || true
	$(shell) test -d /run/systemd/system && systemctl disable ${PACKAGE} && systemctl daemon-reload || true

clean-local:
	-rm -rf .${ETC}
