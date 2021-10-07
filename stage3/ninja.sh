#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource ninja
strapyChrootCd ninja-*


printInfo "Configuring ninja"

strapyChroot cmake . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \

printInfo "Building ninja"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing ninja"
strapyChroot cp ninja /usr/bin/ninja
