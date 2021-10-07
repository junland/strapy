#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource xz
strapyChrootCd xz-*


printInfo "Configuring xz"
# Enable largefile support
export CFLAGS="${CFLAGS} -D_FILE_OFFSET_BITS=64"
strapyChroot ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --enable-shared \
    --disable-static


printInfo "Building xz"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing xz"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
