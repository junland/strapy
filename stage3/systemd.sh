#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource systemd
serpentChrootCd systemd-*


printInfo "Configuring systemd"
serpentChroot meson --prefix=/usr --buildtype=plain build

printInfo "Building systemd"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -C build

printInfo "Installing systemd"
serpentChroot ninja install -j "${SERPENT_BUILD_JOBS}" -C build
