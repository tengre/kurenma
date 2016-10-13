##
## $Id: Makefile.am 104 2016-10-13 09:45:43+04:00 toor $
##
#
AUTOMAKE_OPTIONS	= -Wno-portability
#
PACKAGE			= kurenma
ETC			= /etc
bin_SCRIPTS		= update-firehol gen-ssl-kurenma setup-knockd
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
syslib_DATA		= knockd.conf.example openssl.cnf.template client.kurenma.src server.kurenma.src
PACKAGEVERSION		= $(shell test -f ../ChangeLog && sed -n "3p" ../ChangeLog | sed -e "s/.*Version.//")
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
	$(shell) which systemctl || update-rc.d ${systemv_SCRIPTS} defaults || true
	$(shell) which systemctl && chmod -x ${systemvdir}/${systemv_SCRIPTS} && mv -v ${systemvdir}/${systemv_SCRIPTS} ${systemvdir}/${systemv_SCRIPTS}.disabled-by-systemd || true
	$(shell) which systemctl && systemctl enable ${PACKAGE} && systemctl daemon-reload || true

uninstall-hook:
	$(shell) which systemctl || update-rc.d -f ${systemv_SCRIPTS} remove || true
	$(shell) which systemctl && rm -f ${systemvdir}/${systemv_SCRIPTS}.disabled-by-systemd || true
	$(shell) which systemctl && systemctl disable ${PACKAGE} && systemctl daemon-reload || true

clean-local:
	-rm -rf .${ETC}

all:
	$(shell) sed -i -e "s/_kurenma_sVersion=.*/_kurenma_sVersion=${PACKAGEVERSION}/" kurenmactl
	$(shell) sed -i -e "s/_kurenma_sVersion=.*/_kurenma_sVersion=${PACKAGEVERSION}/" kurenmad
