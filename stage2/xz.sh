#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource xz
cd xz-*


printInfo "Configuring xz"
# Enable largefile support
export CFLAGS="${CFLAGS} -D_FILE_OFFSET_BITS=64"
./configure --prefix=/usr \
    --target="${STRAPY_TRIPLET}" \
    --host="${STRAPY_HOST}" \
    --enable-shared \
    --disable-static \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin


printInfo "Building xz"
make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing xz"
make -j "${STRAPY_BUILD_JOBS}" install DESTDIR="${STRAPY_INSTALL_DIR}"
