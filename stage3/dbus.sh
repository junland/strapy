#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource dbus
strapyChrootCd dbus-*


printInfo "Configuring dbus"

strapyChroot ./configure \
    --build="${STRAPY_TRIPLET}" \
    --host="${STRAPY_TRIPLET}" \
    --prefix=/usr \
    --sysconfdir=/etc \
    --libdir=/usr/lib \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --datadir=/usr/share \


printInfo "Building dbus"
strapyChroot make -j "${STRAPY_BUILD_JOBS}"

printInfo "Installing dbus"
strapyChroot make -j "${STRAPY_BUILD_JOBS}" install

# Clean up unwanted files
rm "${STRAPY_INSTALL_DIR}/usr/bin/dbus-daemon"
rm "${STRAPY_INSTALL_DIR}/usr/lib/systemd/system/dbus.service"
rm "${STRAPY_INSTALL_DIR}/usr/lib/systemd/system/dbus.socket"
rm "${STRAPY_INSTALL_DIR}/usr/lib/systemd/system/sockets.target.wants/dbus.socket"
rm "${STRAPY_INSTALL_DIR}/usr/lib/systemd/system/multi-user.target.wants/dbus.service"
