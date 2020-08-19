#!/usr/bin/env bash

export SERPENT_STAGE_NAME="stage3"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))

COMPONENTS=(
    "root"
    "headers"
    "musl"
    "zlib"
    "xz"
    "diffutils"
    "ncurses"
    "bash"
    "coreutils"
    "util-linux"
    "libarchive"
)

checkRootUser

requireTools "mknod"

prefetchSources
mkdir ${SERPENT_BUILD_DIR} #No builds yet, no dir yet.
bringUpMounts

for component in ${COMPONENTS[@]} ; do
    /usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" bash --norc --noprofile "${executionPath}/${component}.sh"  || serpentFail "Building ${component} failed"
done

takeDownMounts

