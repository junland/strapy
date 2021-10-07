#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource which
strapyChrootCd which-*


printInfo "Configuring which"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building which"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing which"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
