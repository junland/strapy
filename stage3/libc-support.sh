#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

if [[ "${SERPENT_LIBC}" != "musl" ]]; then
    printInfo "Skipping libc-support with non-musl libc"
    exit 0
fi

serpentChrootCd libc-support
git clone https://dev.serpentos.com/source/libc-support.git

printInfo "Configuring libc-support"
serpentChroot meson --prefix=/usr --buildtype=plain build

printInfo "Building libc-support"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -C build

printInfo "Installing libc-support"
serpentChroot ninja install -j "${SERPENT_BUILD_JOBS}" -C build
