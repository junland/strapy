#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource jansson
strapyChrootCd jansson-*

printInfo "Configuring jansson"

strapyChroot cmake . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DJANSSON_BUILD_SHARED_LIBS=ON


printInfo "Building jansson"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing jansson"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install
