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

export SERPENT_STAGE_NAME="stage3"

. $(dirname $(realpath -s $0))/../lib/build.sh

executionPath=$(dirname $(realpath -s $0))

checkRootUser

requireTools "mknod"

[ -d "${SERPENT_INSTALL_DIR}" ] || serpentFail "${SERPENT_INSTALL_DIR} doesn't exist, aborting!"

bringUpMounts

echo 'export PS1="(chroot/bash-\v/${SERPENT_TRIPLET}) : [\w]\n\\$ "' > "${SERPENT_INSTALL_DIR}/etc/profile"
echo "alias ls='ls --color=auto -F'" >> "${SERPENT_INSTALL_DIR}/etc/profile"

if [[ "${SERPENT_TARGET_ARCH}" != "${SERPENT_ARCH}" ]]; then
        requireTools "${SERPENT_QEMU_USER_STATIC}"
        installQemuStatic
        # should fire up qemu static instead?
else
        chroot "${SERPENT_INSTALL_DIR}" /bin/bash -i
fi

takeDownMounts
