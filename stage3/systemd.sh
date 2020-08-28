#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource systemd
serpentChrootCd systemd-*

pushd systemd-*
# Ensure sys/file.h is used for LOCK_EX
patch -p1 < "${SERPENT_PATCHES_DIR}/systemd/0001-partition-makefs-Include-missing-sys-file.h-header.patch"

# Testing / not upstreamed
# Use net/if_arp.h NOT linux/if_arp.h
# When including linux/if_ether.h, include netinet/if_ether.h first
patch -p1 < "${SERPENT_PATCHES_DIR}/systemd/in-progress.patch"
patch -p1 < "${SERPENT_PATCHES_DIR}/systemd/includes.patch"

printInfo "Enabling libwildebeest workarounds"

# If we don't enable __UAPI_DEF_ETHDR=0 then the private if_ether header gets used and breaks the world.
export CFLAGS="${CFLAGS} `serpentChroot pkg-config --cflags --libs libwildebeest` -Wno-unused-command-line-argument -D__UAPI_DEF_ETHHDR=0"

#
# Disabled:
#
#       - *-tests: Various macro expansion failures
#       - nss-*: We don't supportly support NSS
#       - ldconfig: We don't need/support ldconfig
#       - utmp: Not supported properly in musl
printInfo "Configuring systemd"
serpentChroot meson --buildtype=plain build \
        --prefix=/usr \
        -Dutmp=false \
        -Dtests=false \
        -Dfuzz-tests=false \
        -Dslow-tests=false \
        -Dinstall-tests=false \
        -Dldconfig=false \
        -Dnss-systemd=false \
        -Dnss-resolve=false \
        -Dnss-mymachines=false \
        -Dnss-myhostname=false

printInfo "Building systemd"
serpentChroot ninja -j "${SERPENT_BUILD_JOBS}" -C build

printInfo "Installing systemd"
serpentChroot ninja install -j "${SERPENT_BUILD_JOBS}" -C build
