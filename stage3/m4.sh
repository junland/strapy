#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource m4
strapyChrootCd m4-*

cd m4-*

printInfo "Configuring m4"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building m4"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing m4"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
