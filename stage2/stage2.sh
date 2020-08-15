#!/usr/bin/env bash

export SERPENT_STAGE_NAME="stage2"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))

COMPONENTS=(
    "root"
    "headers"
    "musl"
    "zlib"
    "libffi"
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
    "autoconf"
    "automake"
    "m4"
    "make"
    "gawk"
    "grep"
    "sed"
    "patch"
    "less"
    "which"
    "intltool"
    "slibtool"
    "libxml2"
    "bison"
    "gdbm"
    "expat"
    "db"
    "perl"
    "gperf"
)

prefetchSources

for component in ${COMPONENTS[@]} ; do
    /usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" bash --norc --noprofile "${executionPath}/${component}.sh"  || serpentFail "Building ${component} failed"
done
