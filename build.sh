#!/bin/sh

set -x

export BUILDDIR=`pwd`

NCPU=4
uname -s | grep -i "linux" && NCPU=`cat /proc/cpuinfo | grep -c -i processor`

NDK=`which ndk-build`
NDK=`dirname $NDK`
NDK=`greadlink -f $NDK`

cd $BUILDDIR
[ -e openssl-1.0.1h.tar.gz ] || {
    wget http://www.openssl.org/source/openssl-1.0.1h.tar.gz
} || exit 1

for ARCH in armeabi armeabi-v7a x86; do

cd $BUILDDIR
mkdir -p $ARCH
cd $BUILDDIR/$ARCH

# =========== OpenSSL ===========

[ -e lib/libssl.a ] || {

	[ -d openssl-1.0.1h ] || tar xvzf $BUILDDIR/openssl-1.0.1h.tar.gz || exit 1

	cd openssl-1.0.1h

	. $BUILDDIR/setCrossEnvironment-$ARCH.sh

	./Configure \
		android no-shared \
		--prefix=`pwd`/.. \
		--openssldir=openssl \
		|| exit 1

	make all install_sw > ../build.log 2>&1 || exit 1

	cd ..

#	for f in libiconv libcharset; do
#		cp -f lib/$f.so ./
#		$BUILDDIR/setCrossEnvironment-$ARCH.sh \
#			sh -c '$STRIP'" $f.so"
#	done

} || exit 1

done # for ARCH in *

exit 0
