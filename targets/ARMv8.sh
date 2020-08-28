#!/bin/true

. $(dirname $(realpath -s $0))/../lib/base.sh

# The ARMv8(a) profile is intended primarily for the Rockchip RK3399, found
# in the Pinebook Pro. This profile should also support Rasberry Pi 4  too.

export SERPENT_TARGET_CFLAGS="-march=armv8-a+crc -mtune=cortex-a72 -O3"
export SERPENT_TARGET_CXXFLAGS="${SERPENT_TARGET_CFLAGS}"
export SERPENT_TARGET_LDFLAGS=""
export SERPENT_TRIPLET="aarch64-serpent-linux-musl"
export SERPENT_TARGET_LLVM_BACKEND="AArch64"
export SERPENT_TARGET_ARCH="arm64"

# The inlude directory in musl
export SERPENT_TARGET_MUSL="aarch64"

# The qemu-user-static binary we need
export SERPENT_QEMU_USER_STATIC="qemu-aarch64-static"
