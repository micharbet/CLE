#
# CLE installation for packaging purposes
#

DEST=pkg

BINDIR=${DEST}/usr/bin
SHAREDIR=${DEST}/usr/share/cle

clerc: clerc.sh
	sed -e  '/^[[:space:]]*#:/d' -e 's/#:.*//' <clerc.sh >clerc-t
	grep -vi -e debug -e dbg clerc-t >clerc
	chmod 755 clerc
	rm clerc-t

install: clerc
	mkdir -p -m 0755 ${BINDIR}
	mkdir -p -m 0755 ${SHAREDIR}
	mkdir -p -m 0755 ${SHAREDIR}/modules
	mkdir -p -m 0755 ${SHAREDIR}/doc
	install -m 0755 bin/cle ${BINDIR}
	install -m 0755 clerc ${SHAREDIR}
	install -m 0644 modules/* ${SHAREDIR}/modules
	install -m 0644 doc/* ${SHAREDIR}/doc
	
