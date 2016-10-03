##
## $Id: Makefile.am 90 2016-10-03 22:24:28+04:00 toor $
##
#
AUTOMAKE_OPTIONS	= -Wno-portability
#
DOC			= /usr/share/doc
docdir			= ${DOC}/${PACKAGE}/html
doc_DATA		= $(wildcard *.html) $(wildcard *.css)
man1_XMLS		= kurenmactl.1.xml kurenmad.1.xml gen-ssl-kurenma.1.xml setup-knockd.1.xml update-firehol.1.xml
man1_MANS		= kurenmactl.1 kurenmad.1 gen-ssl-kurenma.1 setup-knockd.1 update-firehol.1
man5_XMLS		= kurenma.ini.5.xml dn.kurenma.ini.5.xml
man5_MANS		= kurenma.ini.5 dn.kurenma.ini.5
DESTDIR			=
DB2MAN 			= /usr/share/sgml/docbook/stylesheet/xsl/docbook-xsl/manpages/docbook.xsl
XP     			= xsltproc -''-nonet -''-param man.charmap.use.subset "0"

${man1_MANS} : ${man1_XMLS}
	$(XP) $(DB2MAN) $(subst ,.xml,$@)

$(man5_MANS) : $(man5_XMLS)
	$(XP) $(DB2MAN) $(subst ,.xml,$@)

all:
	$(shell) cd .. && robodoc && cd ./doc && patch < ${PACKAGE}.html.patch
