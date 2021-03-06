#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource util-linux
strapyChrootCd util-linux-*


printInfo "Configuring util-linux"

strapyChroot ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --disable-makeinstall-chown \
    --disable-makeinstall-setuid \


printInfo "Building util-linux"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing util-linux"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
