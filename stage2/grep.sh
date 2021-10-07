#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource grep
cd grep-*


printInfo "Configuring grep"
./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --disable-perl-regexp


printInfo "Building grep"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing grep"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"
