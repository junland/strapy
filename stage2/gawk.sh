#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource gawk
cd gawk-*


printInfo "Configuring gawk"
./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin


printInfo "Building gawk"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing gawk"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"
