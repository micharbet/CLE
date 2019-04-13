#
# CLE installation for packaging purposes
#

DEST=pkg
BINDIR=${DEST}/usr/bin
SHAREDIR=${DEST}/usr/share/cle

all: clerc modules/modulist

# strip down clerc.sh
# - remove all debug lines
# - remove extended comments '#:'
clerc: clerc.sh
	@ sed -e '/dbg_/d' -e '/#.*dbg/d' clerc.sh >clerc-nodebug
	@ sed -e '/^\s*#:/d' -e 's/\(^#\s\)*\s*#:.*/\1/'  clerc-nodebug >clerc
	@ rm clerc-nodebug
	@ chmod 755 clerc
	@ ls -l $@

# create module index
modules/modulist: modules/mod-* modules/cle-*
	@ rm $@
	@ for M in $^; do \
		MM=$$(basename $$M); \
		VER=$$(sed -n "s/^#\* version:\s*//p" $$M); \
		SUM=$$( md5sum $$M | cut -d' ' -f1 ); \
		DSC=$$(sed -n "/^##/s/.*$$MM:\s*\([^*]*\)\**/\1/p" $$M); \
		echo $$MM:$$VER:$$SUM:$$DSC; \
	done >$@
	@ ls -l $@
	
# This will be used for packaging
install: clerc
	mkdir -p -m 0755 ${BINDIR}
	mkdir -p -m 0755 ${SHAREDIR}
	mkdir -p -m 0755 ${SHAREDIR}/modules
	mkdir -p -m 0755 ${SHAREDIR}/doc
	install -m 0755 bin/cle ${BINDIR}
	install -m 0755 clerc ${SHAREDIR}
	install -m 0644 modules/* ${SHAREDIR}/modules
	install -m 0644 doc/* ${SHAREDIR}/doc
	
