#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource nghttp2
serpentChrootCd nghttp2-*

printInfo "Configuring nghttp2"

serpentChroot cmake . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \


printInfo "Building nghttp2"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing nghttp2"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
