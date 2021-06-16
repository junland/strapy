#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh


serpentChrootCd boulder

printInfo "Cloning boulder"
git clone --recurse-submodules https://gitlab.com/serpent-os/core/boulder.git

printInfo "Building boulder"
serpentChroot ./scripts/build.sh

printInfo "Installing boulder"
cp "${SERPENT_BUILD_DIR}/boulder/bin/boulder" "${SERPENT_INSTALL_DIR}/usr/bin/"
rm -rf "${SERPENT_INSTALL_DIR}/usr/share/moss/"
cp -a "${SERPENT_BUILD_DIR}/boulder/data" "${SERPENT_INSTALL_DIR}/usr/share/moss/"
