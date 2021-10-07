#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource coreutils
strapyChrootCd coreutils-*
pushd coreutils-*


printInfo "Configuring coreutils"
export FORCE_UNSAFE_CONFIGURE=1
strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --enable-largefile \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \
    --enable-single-binary


printInfo "Building coreutils"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing coreutils"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
