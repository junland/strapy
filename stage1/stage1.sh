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

export SERPENT_STAGE_NAME="stage1"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))

COMPONENTS=(
    "headers"
    "toolchain"
    "compiler-rt"
    "${SERPENT_LIBC}"
    "toolchain-extra"
    "libffi"
    "pkgconf"
)

prefetchSources

for component in ${COMPONENTS[@]} ; do
    /usr/bin/env -S -i SERPENT_TARGET="${SERPENT_TARGET}" SERPENT_LIBC="${SERPENT_LIBC}" bash --norc --noprofile "${executionPath}/${component}.sh" || serpentFail "Building ${component} failed"
done
