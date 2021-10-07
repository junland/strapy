#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource coreutils
cd coreutils-*


printInfo "Configuring coreutils"
# Disable broke manpages
sed -i Makefile.am -e '/man\/local.mk/d'
autoreconf -vfi

export FORCE_UNSAFE_CONFIGURE=1
./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --disable-acl \
    --disable-nls \
    --enable-largefile \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --disable-single-binary


printInfo "Building coreutils"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing coreutils"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"
