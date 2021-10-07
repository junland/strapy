#!/usr/bin/env bash

########################################################################
#                                                                      #
# Stage: One                                                           #
#                                                                      #
# Our aim here is to bootstrap an absolutely minimal cross-compiler    #
# for the target system. It will be used to build the entirety of      #
# stage2.                                                              #
#                                                                      #
########################################################################

export STRAPY_STAGE_NAME="stage1"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))

COMPONENTS=(
    "headers"
    "binutils"
    "toolchain"
    "compiler-rt"
    "gcc"
    "${STRAPY_LIBC}"
    "toolchain-extra"
    "libffi"
    "pkgconf"
)

prefetchSources

for component in ${COMPONENTS[@]} ; do
    /usr/bin/env -S -i STRAPY_TARGET="${STRAPY_TARGET}" STRAPY_LIBC="${STRAPY_LIBC}" bash --norc --noprofile "${executionPath}/${component}.sh" || strapyFail "Building ${component} failed"
done
