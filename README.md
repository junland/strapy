## bootstrap-scripts

This is our work-in-progress repository for bootstrapping the initial Serpent OS images,
which we then use to produce the first self hosting repositories. As explained publicly,
our timescale means that proper development isn't **yet** at full cadence.

Eventually we're looking at simple, configurable shell scripts to automatically build
stage1 + stage2 + stage3 toolchains, and a corresponding chrootable image which
we'll use as a simple base to flesh out basic requirements, package management, etc.

When package management features are complete, including build tools, one will need to
use a bootstrap image to complete a full bootstrap for a self hosting image.

We plan to make these scripts flexible enough to handle a variety of hardware configurations,
although for initial simplicty (and lack of appropriate hardware) we'll just focus on
x86_64 hardware.

### Requirements

 - `glibc-2.33`
 - Host `zlib`
 - Working host toolchain (`gcc`or `clang`)
 - `curl`  binary in path
 - non-stupid `tar`
 - `bash` - Yes, these are bash scripts.


#### stage1

Build a minimal cross-compiler for the target, with supporting C/C++ runtime libraries.

#### stage2

Use stage1 to cross-compile essentials for a working chroot, and freshly cross-compiled 'native' clang

#### stage3

Reuse stage1 to build glibc + headers.
Reuse stage2 at `/strapy` in a chroot to build a clean stage3 install.

### Multiarch testing

It is advised you install the correct qemu-user-static within your path so that the cross-compilation
stages can make use of it.

For example, fetch `x86_64_qemu-aarch64-static.tar.gz` from the [multiarch](https://github.com/multiarch/qemu-user-static/releases) project,
to be able to chroot into an AArch64 environment from an x86_64 host.

Extract the archive, and install `qemu-aarch64-static` to `/usr/bin` or similar.

You'll need to ensure `binfmt_misc` is configured appropriately, for example, as root:

```bash
echo ':aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7:\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff:/usr/bin/qemu-aarch64-static:' > /proc/sys/fs/binfmt_misc/register
```

### Bootstrap build instructions

#### Build Requirements

Check that your distro uses `glibc-2.33` as this is required for a successful bootstrap.

##### Arch

```
sudo pacman -Syu base-devel
sudo pacman -Syu cmake ldc meson ninja texinfo
```

##### Fedora

```
sudo dnf group install 'Development Tools'
sudo dnf install automake bison cmake gettext-devel ldc meson ninja-build texinfo
```

#### Build the bootstrap stages

Clone the bootstrap-scripts somewhere appropriate, then

```
cd bootstrap-scripts/
time stage1/stage1.sh > stage1.log 2>&1
time stage2/stage2.sh > stage2.log 2>&1
time sudo stage3/stage3.sh > stage3.log 2>&1
```

##### Rebuilding a bootstrap stage

If you need to rebuild a stage, do a `sudo rm -rf install/<arch>/<libc>/<stage>` first.

##### Tips and Tricks for watching the bootstrap builds

During the build, you can use either `tail -f <stage>.log` or `less -R <stage>.log` in a different terminal.

When using `less`, press `F` to follow the build status in real-time.

Press <CTRL+C> to quit follow mode and press ´q´ to quit less.

#### Chroot-ing into the freshly built stage3/4

`sudo stage4/chroot.sh`
