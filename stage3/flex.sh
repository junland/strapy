#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource flex
strapyChrootCd flex-*


printInfo "Configuring flex"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building flex"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing flex"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
