#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource dbus-broker
strapyChrootCd dbus-broker-*


printInfo "Configuring dbus-broker"
strapyChroot meson --buildtype=plain build \
        --prefix=/usr \


printInfo "Building dbus-broker"
strapyChroot ninja -j "${STRAPY_BUILD_JOBS}" -C build

printInfo "Installing dbus-broker"
strapyChroot ninja install -j "${STRAPY_BUILD_JOBS}" -C build

# Make dbus-broker the default
ln -svf ../dbus-broker.service "${STRAPY_INSTALL_DIR}/usr/lib/systemd/system/multi-user.target.wants/dbus-broker.service"
