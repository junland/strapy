#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource openssl
serpentChrootCd openssl-*


printInfo "Configuring openssl"

serpentChroot ./Configure \
    --prefix=/usr \
    --libdir=/usr/lib \


printInfo "Building openssl"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing openssl"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
