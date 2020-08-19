#!/usr/bin/env bash

########################################################################
#                                                                      #
# Stage: Three                                                         #
#                                                                      #
# We construct a chroot environment that has an empty layout, that is  #
# used to natively build the final system. To achieve this, some quick #
# compatibility work is done, such as building musl and the system     #
# headers.
#
# We bind-mount the stage2 support environment to the /serpent tree    #
# and add it to the end of the PATH environmental variable. This lets  #
# us use the native compiler, libs, etc, to natively build all of our  #
# needed software and install to the root of the tree.                 #
#                                                                      #
########################################################################

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

