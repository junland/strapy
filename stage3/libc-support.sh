#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

serpentChrootCd libc-support
git clone https://dev.serpentos.com/source/libc-support.git

printInfo "Configuring libc-support"

serpentChroot sh autogen.sh \
    --build="${SERPENT_TRIPLET}" \
    --host="${SERPENT_TRIPLET}"

printInfo "Building libc-support"
serpentChroot make -j "${SERPENT_BUILD_JOBS}"

printInfo "Installing libc-support"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install
