#!/bin/true

. $(dirname $(realpath -s $0))/../lib/base.sh

# The ARMv8(a) profile is intended primarily for the Rockchip RK3399, found
# in the Pinebook Pro. This profile should also support Rasberry Pi 4  too.

export STRAPY_TARGET_CFLAGS="-march=armv8-a+simd+fp+crypto -mtune=cortex-a72 -O2 -pipe -fPIC"
export STRAPY_TARGET_CXXFLAGS="${STRAPY_TARGET_CFLAGS}"
export STRAPY_TARGET_LDFLAGS=""
export STRAPY_TRIPLET="aarch64-strapy-linux"

if [[ "${STRAPY_LIBC}" == "musl" ]]; then
    export STRAPY_TRIPLET="${STRAPY_TRIPLET}-musl"
fi

export STRAPY_TARGET_LLVM_BACKEND="AArch64"
export STRAPY_TARGET_ARCH="arm64"

# The inlude directory in musl
export STRAPY_TARGET_MUSL="aarch64"

# The qemu-user-static binary we need
export STRAPY_QEMU_USER_STATIC="qemu-aarch64-static"
