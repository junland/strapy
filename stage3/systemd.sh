#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource systemd
serpentChrootCd systemd-*

pushd systemd-*
# Ensure sys/file.h is used for LOCK_EX
patch -p1 < "${SERPENT_PATCHES_DIR}/systemd/0001-partition-makefs-Include-missing-sys-file.h-header.patch"

printInfo "Enabling libwildebeest workarounds"

# If we don't enable __UAPI_DEF_ETHDR=0 then the private if_ether header gets used and breaks the world.
export CFLAGS="${CFLAGS} `serpentChroot pkg-config --cflags --libs libwildebeest` -Wno-unused-command-line-argument -D__UAPI_DEF_ETHHDR=0"

# Many fails are due to missing gshadow, which is our current priority after finishing stubs
# Some fail for networking reasons and can be re-enabled in future
# NSS we currently disable as we're not *yet* using it.
printInfo "Configuring systemd"
serpentChroot meson --buildtype=plain build \
        --prefix=/usr \
        -Dgshadow=false \
        -Dtmpfiles=false \
        -Dnetworkd=false \
        -Dtests=false \
        -Dfuzz-tests=false \
        -Dslow-tests=false \
        -Dinstall-tests=false \
        -Dresolve=false \
        -Dldconfig=false \
        -Duserdb=false \
        -Dnss-systemd=false \
        -Dnss-resolve=false \
        -Dnss-mymachines=false \
        -Dnss-myhostname=false

printInfo "Building systemd"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -C build

printInfo "Installing systemd"
serpentChroot ninja install -j "${SERPENT_BUILD_JOBS}" -C build
