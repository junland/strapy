#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource rocksdb
serpentChrootCd rocksdb-*


printInfo "Configuring rocksdb"

serpentChroot cmake . -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DWITH_GFLAGS=OFF

printInfo "Building ninja"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing ninja"
serpentChroot ninja install -j "${SERPENT_BUILD_JOBS}"
