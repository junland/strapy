#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" != "musl" ]]; then
    printInfo "Skipping dash with non-musl libc"
    exit 0
fi

extractSource dash
cd dash-*


printInfo "Configuring dash"
./configure --prefix=/usr \
    --target="${SERPENT_TRIPLET}" \
    --host="${SERPENT_HOST}" \
    --enable-static

printInfo "Building dash"
make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing dash"
make -j "${SERPENT_BUILD_JOBS}" install DESTDIR="${SERPENT_INSTALL_DIR}"
ln -svf dash "${SERPENT_INSTALL_DIR}/usr/bin/sh"
