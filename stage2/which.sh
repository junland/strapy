#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource which
cd which-*


printInfo "Configuring which"
./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin


printInfo "Building which"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing which"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"
