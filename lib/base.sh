#!/bin/true

# Common functionality between all stages


# Emit a warning to tty
function printWarning()
{
    echo -en '\e[1m\e[93m[WARNING]\e[0m '
    echo -e $*
}

# Emit an error to tty
function printError()
{
    echo -en '\e[1m\e[91m[ERROR]\e[0m '
    echo -e $*
}

# Emit info to tty
function printInfo()
{
    echo -en '\e[1m\e[94m[INFO]\e[0m '
    echo -e $*
}

# Failed to do a thing. Exit fatally.
function serpentFail()
{
    printError $*
    exit 1
}

# Check tools can be found
function requireTools()
{
    for tool in $* ; do
        which "${tool}" &>/dev/null  || serpentFail "Missing host executable: ${tool}"
    done
}

# Check we're running as the root user
function checkRootUser()
{
    [ "${EUID}" -eq "0" ] || serpentFail "$0: Must be run via sudo"
    [ ! -z "${SUDO_USER}" ] || serpentFail "SUDO_USER incorrectly set"
}

# Tightly control the path
export PATH="/usr/bin:/bin/:/sbin:/usr/sbin"

export SERPENT_ROOT_DIR="$(dirname $(dirname $(realpath -s ${BASH_SOURCE[0]})))"

export SERPENT_BUILD_ROOT="${SERPENT_ROOT_DIR}/build"
export SERPENT_DOWNLOAD_DIR="${SERPENT_ROOT_DIR}/downloads"
export SERPENT_INSTALL_ROOT="${SERPENT_ROOT_DIR}/install"
export SERPENT_SOURCES_DIR="${SERPENT_ROOT_DIR}/sources"
export SERPENT_PATCHES_DIR="${SERPENT_ROOT_DIR}/patches"

# Basic validation.
[ -d "${SERPENT_SOURCES_DIR}" ] || serpentFail "Missing source tree"

export LANG="C"
export LC_ALL="C"
