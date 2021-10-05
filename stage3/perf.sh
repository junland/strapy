#!/bin/true
set -e

. $(dirname $(realpath -s $0))/common.sh

extractSource linux
serpentChrootCd linux-*


printInfo "Building perf"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" -C tools/perf prefix=/usr

printInfo "Installing perf"
serpentChroot make -j "${SERPENT_BUILD_JOBS}" install -C tools/perf prefix=/usr

