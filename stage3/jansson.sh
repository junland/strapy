#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource jansson
serpentChrootCd jansson-*

printInfo "Configuring jansson"

serpentChroot cmake . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DJANSSON_BUILD_SHARED_LIBS=ON


printInfo "Building jansson"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing jansson"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
