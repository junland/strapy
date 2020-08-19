#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource util-linux
serpentChrootCd util-linux-*


printInfo "Configuring util-linux"

serpentChroot ./configure --prefix=/usr \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}" \
    --disable-nls \
    --without-systemd \
    --without-udev \
    --without-python \
    --without-libmagic \
    --without-readline \
    --without-cryptsetup \
    --without-btrfs \
    --without-audit \
    --without-user \
    --without-selinux \
    --without-smack \
    --enable-largefile \
    --disable-plymouth_support \
    --libdir=/usr/lib \
    --disable-hardlink \
    --disable-rpath \
    --disable-makeinstall-chown \
    --disable-makeinstall-setuid \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --disable-hwclock-cmos


printInfo "Building util-linux"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing util-linux"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install