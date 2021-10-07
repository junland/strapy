#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource make
cd make-*


printInfo "Configuring make"
./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --without-guile


printInfo "Building make"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing make"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"

# Include for compat purposes, may not be needed
ln -sv make "${STRAPY_INSTALL_DIR}/usr/bin/gmake"
