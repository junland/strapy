#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource dbus-broker
serpentChrootCd dbus-broker-*


printInfo "Configuring dbus-broker"
serpentChroot meson --buildtype=plain build \
        --prefix=/usr \


printInfo "Building dbus-broker"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -C build

printInfo "Installing dbus-broker"
serpentChroot ninja install -j "${SERPENT_BUILD_JOBS}" -C build
