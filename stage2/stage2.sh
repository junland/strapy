#!/usr/bin/env bash

export SERPENT_STAGE_NAME="stage2"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))

COMPONENTS=(
    "root"
    "headers"
    "musl"
    "zlib"
    "toolchain"
    "attr"
    "acl"
    "ncurses"
    "bash"
    "gzip"
    "xz"
    "util-linux"
    "coreutils"
    "openssl"
    "libarchive"
)

prefetchSources

for component in ${COMPONENTS[@]} ; do
    /usr/bin/env -S -i bash --norc --noprofile "${executionPath}/${component}.sh"  || serpentFail "Building ${component} failed"
done
