#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh


serpentChrootCd boulder

export CFLAGS="${CFLAGS} -fuse-ld=lld"
export CXXFLAGS="${CXXFLAGS} -fuse-ld=lld"
export LDFLAGS="${LDFLAGS} -fuse-ld=lld"

printInfo "Cloning boulder"
git clone --recurse-submodules https://github.com/serpent-linux/boulder.git

printInfo "Building boulder"
serpentChroot ./scripts/build.sh
