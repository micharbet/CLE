#
# CLE installation for packaging purposes
#
BINDIR=${DESTDIR}/usr/bin
SHAREDIR=${DESTDIR}/usr/share/cle

install:
	mkdir -p -m 0755 ${BINDIR}
	mkdir -p -m 0755 ${SHAREDIR}
	mkdir -p -m 0755 ${SHAREDIR}/modules
	mkdir -p -m 0755 ${SHAREDIR}/doc
	install -m 0755 bin/cle ${BINDIR}
	install -m 0755 clerc ${SHAREDIR}
	install -m 0644 modules/* ${SHAREDIR}/modules
	install -m 0644 doc/* ${SHAREDIR}/doc
	
