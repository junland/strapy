#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh


serpentChrootCd moss

printInfo "Cloning moss"
git clone --recurse-submodules https://github.com/serpent-linux/moss.git

printInfo "Building moss"
serpentChroot ./scripts/build.sh
