##
## $Id: Makefile.am 228 2019-06-14 00:46:18+04:00 yds $
##
#
AUTOMAKE_OPTIONS	= -Wno-portability
#
DOC			= /usr/share/doc
docdir			= ${DOC}/${PACKAGE}/html
doc_DATA		= $(wildcard *.html) $(wildcard *.css)
man5_XMLS		= kurenma.ini.5.xml dn.kurenma.ini.5.xml ipslist.ini.5.xml
man5_MANS		= kurenma.ini.5 dn.kurenma.ini.5 ipslist.ini.5
man7_XMLS		= kurenma.7.xml
man7_MANS		= kurenma.7
man8_XMLS		= kurenmactl.8.xml kurenmad.8.xml kurenma-ssl-gen.8.xml kurenma-knockd-setup.8.xml kurenma-firehol-update.8.xml
man8_MANS		= kurenmactl.8 kurenmad.8 kurenma-ssl-gen.8 kurenma-knockd-setup.8 kurenma-firehol-update.8
DESTDIR			=
DB2MAN 			= /usr/share/sgml/docbook/stylesheet/xsl/docbook-xsl/manpages/docbook.xsl
XP     			= xsltproc -''-nonet -''-param man.charmap.use.subset "0" -param man.justify "1"
BUILD_DATE              = $(shell test -f ../VERSION && cut -f 3 -d' ' ../VERSION || date '+%Y-%m-%d')

$(man5_MANS) : $(man5_XMLS)
	$(XP) $(DB2MAN) $(subst ,.xml,$@)

${man7_MANS} : ${man7_XMLS}
	$(XP) $(DB2MAN) $(subst ,.xml,$@)

${man8_MANS} : ${man8_XMLS}
	$(XP) $(DB2MAN) $(subst ,.xml,$@)

all:
	$(shell) cd .. && robodoc && cd ./doc && patch < kurenma.html.patch && sed -i -re "s/^(<p>Generated.from.*V.*on).*/\1 ${BUILD_DATE}/ig" kurenma.html
