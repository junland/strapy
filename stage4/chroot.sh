#!/usr/bin/env bash

########################################################################
#                                                                      #
# Stage: Three                                                         #
#                                                                      #
# We set up the necessary mounts and chroot into a bash instance in    #
# the newly constructed stage3 environment.                            #
#                                                                      #
# This is a convenience function for use in stage4 work.               #
#                                                                      #
# Upon exiting the chroot bash environment, the mounts are properly    #
# torn down.                                                           #
#                                                                      #
########################################################################

export SERPENT_STAGE_NAME="stage4"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))
stage3tree=$(getInstallDir 3)

checkRootUser

requireTools "mknod"

[ -d "${SERPENT_INSTALL_DIR}" ] || serpentFail "${SERPENT_INSTALL_DIR} doesn't exist, aborting!"

# Ensure that mounts already exist
prefetchSources
mkdir -p "${SERPENT_BUILD_DIR}/stones" || serpentFail "Failed to create directory ${SERPENT_BUILD_DIR}/stones"
mkdir -p "${SERPENT_BUILD_DIR}/os" || serpentFail "Failed to create directory ${SERPENT_BUILD_DIR}/os"
createDownloadStore

bringUpMounts

echo 'export PS1="(chroot/bash-\v/${SERPENT_TRIPLET}) : [\w]\n\\$ "' > "${stage3tree}/etc/profile"
echo "alias ls='ls --color=auto -F'" >> "${stage3tree}/etc/profile"

if [[ "${SERPENT_TARGET_ARCH}" != "${SERPENT_ARCH}" ]]; then
        requireTools "${SERPENT_QEMU_USER_STATIC}"
        installQemuStatic
        # should fire up qemu static instead?
else
        chroot "${stage3tree}" /bin/bash -i
fi

takeDownMounts
