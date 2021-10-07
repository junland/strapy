#!/bin/true

# Build stages functionality
export STRAPY_ROOT_DIR="$(dirname $(dirname $(realpath -s ${BASH_SOURCE[0]})))"

. "${STRAPY_ROOT_DIR}/lib/base.sh"

# Set the target Arch to import early for install dir
export STRAPY_TARGET=${STRAPY_TARGET:-"x86_64"}

# Define which libc we wish to use with this build
export STRAPY_LIBC=${STRAPY_LIBC:-"glibc"}

# Make sure the scripts are properly implemented.
[ ! -z "${STRAPY_STAGE_NAME}" ] || strapyFail "Stage name is not set"

# Stage specific directories
export STRAPY_BUILD_DIR="${STRAPY_BUILD_ROOT}/${STRAPY_STAGE_NAME}"
export STRAPY_INSTALL_DIR="${STRAPY_INSTALL_ROOT}/${STRAPY_TARGET}/${STRAPY_LIBC}/${STRAPY_STAGE_NAME}"
export STRAPY_BUILD_SCRIPT=$(basename "${0}")
export STRAPY_BUILD_NAME="${STRAPY_BUILD_SCRIPT%.sh}"
export STRAPY_BUILD_JOBS=$(nproc)

# Helper to get older stage tree
function getInstallDir()
{
    [ ! -z "${1}" ] || strapyFail "Incorrect use of getInstallDir"
    echo "${STRAPY_INSTALL_ROOT}/${STRAPY_TARGET}/${STRAPY_LIBC}/stage${1}"
}

# Verify the download is correct
function verifyDownload()
{
    [ ! -z "${1}" ] || strapyFail "Incorrect use of verifyDownload"
    sourceFile="${STRAPY_SOURCES_DIR}/${1}"
    [ -f "${sourceFile}" ] || strapyFail "Missing source file: ${sourceFile}"
    sourceURL="$(cat ${sourceFile} | cut -d ' ' -f 1)"
    sourceHash="$(cat ${sourceFile} | cut -d ' ' -f 2)"
    [ ! -z "${sourceURL}" ] || strapyFail "Missing URL for source: $1"
    [ ! -z "${sourceHash}" ] || strapyFail "Missing hash for source: $1"
    sourcePathBase=$(basename "${sourceURL}")
    sourcePath="${STRAPY_DOWNLOAD_DIR}/${sourcePathBase}"

    printInfo "Computing hash for ${sourcePathBase}"

    computeHash=$(sha256sum "${sourcePath}" | cut -d ' ' -f 1)
    [ $? -eq 0 ] || strapyFail "Failed to compute SHA256sum"

    if [ "${computeHash}" != "${sourceHash}" ]; then
        rm -v "${sourcePath}"
        strapyFail "Corrupt download: ${sourcePath}\nExpected: ${sourceHash}\nFound: ${computeHash}"
    fi
}

# Download a file from sources/
function downloadSource()
{
    [ ! -z "${1}" ] || strapyFail "Incorrect use of downloadSource"
    sourceFile="${STRAPY_SOURCES_DIR}/${1}"
    [ -f "${sourceFile}" ] || strapyFail "Missing source file: ${sourceFile}"
    sourceURL="$(cat ${sourceFile} | cut -d ' ' -f 1)"
    sourceHash="$(cat ${sourceFile} | cut -d ' ' -f 2)"
    [ ! -z "${sourceURL}" ] || strapyFail "Missing URL for source: $1"
    [ ! -z "${sourceHash}" ] || strapyFail "Missing hash for source: $1"
    sourcePathBase=$(basename "${sourceURL}")
    sourcePath="${STRAPY_DOWNLOAD_DIR}/${sourcePathBase}"

    mkdir -p "${STRAPY_DOWNLOAD_DIR}" || strapyFail "Failed to create download tree"

    if [[ -f "${sourcePath}" ]]; then
        printInfo "Skipping download of ${sourcePathBase}"
        verifyDownload "${1}"
        return
    fi

    if [[ -f "${sourcePath}.partial" ]]; then
        printInfo "Resuming download of ${sourcePathBase}"
        curl -C - -L --fail --ftp-pasv --retry 3 --retry-delay 5 -o "${sourcePath}.partial" "${sourceURL}"
        mv "${sourcePath}.partial" "${sourcePath}" || strapyFail "Failed to move completed resumed file"
        verifyDownload "${1}"
        return
    fi

    printInfo "Downloading ${sourcePathBase}"
    curl -C - -L --fail --ftp-pasv --retry 3 --retry-delay 5 -o "${sourcePath}.partial" "${sourceURL}"
    mv "${sourcePath}.partial" "${sourcePath}" || strapyFail "Failed to move completed downloaded file"
    verifyDownload "${1}"
}

# Extract a tarball into the current working directory
function extractSource()
{
    [ ! -z "${1}" ] || strapyFail "Incorrect use of extractSource"
    sourceFile="${STRAPY_SOURCES_DIR}/${1}"
    [ -f "${sourceFile}" ] || strapyFail "Missing source file: ${sourceFile}"
    sourceURL="$(cat ${sourceFile} | cut -d ' ' -f 1)"
    [ ! -z "${sourceURL}" ] || strapyFail "Missing URL for source: $1"
    sourcePathBase=$(basename "${sourceURL}")
    sourcePath="${STRAPY_DOWNLOAD_DIR}/${sourcePathBase}"

    printInfo "Extracting ${sourcePathBase}"

    tar xf "${sourcePath}" -C . || strapyFail "Failed to extract ${sourcePath}"
}

# Prepare the build tree
function prepareBuild()
{
    export STRAPY_BUILD_DIR="${STRAPY_BUILD_DIR}/${STRAPY_BUILD_NAME}"
    printInfo "Building ${STRAPY_BUILD_NAME} in ${STRAPY_BUILD_DIR}"

    if [[ -d "${STRAPY_BUILD_DIR}" ]]; then
        printWarning "Removing stale build directory"
        rm -rf "${STRAPY_BUILD_DIR}" || strapyFail "Failed to remove stale build directory"
    fi

    mkdir -p "${STRAPY_BUILD_DIR}" || strapyFail "Cannot create working tree"
    cd "${STRAPY_BUILD_DIR}"
}

# Fetch all sources for all builds
function prefetchSources()
{
    printInfo "Prefetching all sources"

    for sourceFile in "${STRAPY_SOURCES_DIR}"/* ; do
        bnom=$(basename "${sourceFile}")
        downloadSource "${bnom}"
    done
}

# Activate the stage1 compiler for use.
function activateStage1Compiler()
{
    export STRAPY_STAGE1_TREE=$(getInstallDir "1")

    if [[ ! -e "${STRAPY_STAGE1_TREE}/usr/bin/clang" ]]; then
        printError "No stage1 compiler found"
        exit 1
    fi

    export PATH="${STRAPY_STAGE1_TREE}/usr/bin:$PATH"

    # Check its the right clang/llvm.
    STRAPY_LLVM_TARGET=$(llvm-config --host-target)
    if [[ $? -ne 0 ]]; then
        printError "Could not run llvm-config"
        exit 1
    fi

    if [[ "${STRAPY_LLVM_TARGET}" != "${STRAPY_TRIPLET}" ]]; then
        printError "Incorrect LLVM target: ${STRAPY_LLVM_TARGET}"
        exit 1
    fi

    printInfo "Using clang/llvm target: ${STRAPY_LLVM_TARGET}"

    unset STRAPY_LLVM_TARGET

    export CC="clang"
    export CXX="clang++"
    export AR="llvm-ar"
    export NM="llvm-nm"
    export OBJDUMP="llvm-objdump"
    export RANLIB="llvm-ranlib"
    export READELF="llvm-readelf"
    export STRIP="llvm-strip"

    # Handle libc specifics for stage1
    if [[ "${STRAPY_LIBC}" == "musl" ]]; then
        export STRAPY_LIBC_FLAGS="-D_LIBCPP_HAS_MUSL_LIBC"
    else
        export STRAPY_LIBC_FLAGS=""
    fi

    export CFLAGS="${STRAPY_TARGET_CFLAGS} -I${STRAPY_INSTALL_DIR}/usr/include -L${STRAPY_STAGE1_TREE}/lib -L${STRAPY_INSTALL_DIR}/usr/lib -Wno-unused-command-line-argument ${STRAPY_LIBC_FLAGS} -Wno-error"
    export CXXFLAGS="${STRAPY_TARGET_CXXFLAGS} -I${STRAPY_INSTALL_DIR}/usr/include -L${STRAPY_STAGE1_TREE}/lib -L${STRAPY_INSTALL_DIR}/usr/lib -Wno-unused-command-line-argument ${STRAPY_LIBC_FLAGS} -Wno-error"
    export LDFLAGS="${STRAPY_TARGET_LDFLAGS} -L${STRAPY_STAGE1_TREE}/lib -L${STRAPY_INSTALL_DIR}/usr/lib"
    export PKG_CONFIG_PATH="${STRAPY_INSTALL_DIR}/usr/lib/pkgconfig:${STRAPY_INSTALL_DIR}/usr/share/pkgconfig"

    unset STRAPY_STAGE1_TREE
}


# Basic validation.
[ -d "${STRAPY_SOURCES_DIR}" ] || strapyFail "Missing source tree"

# Check basic requirements before we go anywhere.
requireTools autoreconf autopoint bison cmake curl gcc g++ ninja patch tar uname

# TODO: Revisit this if needed
export STRAPY_ARCH=$(uname -m)

if [[ -e '/lib/ld-linux-x86-64.so.2' ]] || [[ -e '/lib64/ld-linux-x86-64.so.2' ]]; then
    export STRAPY_HOST="${STRAPY_ARCH}-linux-gnu"
elif [[ -e '/lib/ld-linux-aarch64.so.1' ]] || [[ -e '/lib64/ld-linux-aarch64.so.1' ]]; then
	export STRAPY_HOST="${STRAPY_ARCH}-linux-gnu"
else
    printError "Unsupported host configuration"
    exit 1
fi

[ -e "${STRAPY_ROOT_DIR}/targets/${STRAPY_TARGET}.sh" ] || strapyFail "Failed to load targets/${STRAPY_TARGET}.sh"

unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

printInfo "Using '${STRAPY_TARGET}' build configuration"
source "${STRAPY_ROOT_DIR}/targets/${STRAPY_TARGET}.sh"
