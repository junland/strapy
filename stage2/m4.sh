#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource m4
cd m4-*

printInfo "Configuring m4"
./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin


printInfo "Building m4"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing m4"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"
