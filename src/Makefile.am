##
## $Id: Makefile.am 148 2017-02-20 16:11:11+04:00 toor $
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
PACKAGEDATE		= $(shell git log -1 --pretty=format:"%ci" | cut -f1 -d' ' 2>/dev/null )
PACKAGEVERSION		= $(shell test -f ../ChangeLog && sed -n "3p" ../ChangeLog | sed -e "s/.*Version.//")
PACKAGEREVISION		= $(shell s=$$(git shortlog -s 2>/dev/null | grep -oP '^\s+\d+\s+' | xargs | sed -e "s/ / + /g") && expr $$s + 1 )
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

all:
	$(shell) test -n ${PACKAGEDATE} && sed -i -e "s/_kurenma_sDate=.*/_kurenma_sDate=${PACKAGEDATE}/" kurenmactl
	$(shell) test -n ${PACKAGEDATE} && sed -i -e "s/_kurenma_sDate=.*/_kurenma_sDate=${PACKAGEDATE}/" kurenmad
	$(shell) test -n ${PACKAGEVERSION} && sed -i -e "s/_kurenma_sVersion=.*/_kurenma_sVersion=${PACKAGEVERSION}/" kurenmactl
	$(shell) test -n ${PACKAGEVERSION} && sed -i -e "s/_kurenma_sVersion=.*/_kurenma_sVersion=${PACKAGEVERSION}/" kurenmad
	$(shell) test -n ${PACKAGEREVISION} && sed -i -e "s/_kurenma_sRevision=.*/_kurenma_sRevision=${PACKAGEREVISION}/" kurenmactl
	$(shell) test -n ${PACKAGEREVISION} && sed -i -e "s/_kurenma_sRevision=.*/_kurenma_sRevision=${PACKAGEREVISION}/" kurenmad
