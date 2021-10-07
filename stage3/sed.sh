#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource sed
strapyChrootCd sed-*


printInfo "Configuring sed"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building sed"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing sed"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
