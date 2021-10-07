#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource zlib
cd zlib-*


printInfo "Configuring zlib"

./configure --prefix=/usr \
    --libdir=/usr/lib \
    --enable-shared

printInfo "Building zlib"
make -j "${STRAPY_BUILD_JOBS}"

make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"
