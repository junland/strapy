#!/bin/bash
#
# ugly script to build a docker image from stage3 results.
#
set -e

if [[ "$EUID" -ne "0" ]]; then
    echo "Must be run as root."
    exit 1
fi

rm -rf docker/root
cp -Rav install/x86_64/stage3 docker/root
pushd docker
rm -fv root/config*
rmdir root/build
rmdir root/serpent

# Trim it.
set +e
find root/usr/bin -type f | xargs -I{} strip {}
find root/usr/libexec -type f | xargs -I{} strip {}
find root/usr/lib -type -f -name "*.so*" | xargs -I{} strip {}
rm -v root/usr/lib/*.a
rm -v root/usr/lib/*.la
rm -v root/usr/lib/*.so
rm -vrf root/usr/include
rm -vrf root/usr/share/doc
rm -vrf root/usr/share/man
rm -vrf root/usr/{bin,share,lib}/*perl*
rm -vrf root/usr/{bin,share,lib}/*python*
rm -vrf root/usr/{bin,share,lib}/*cmake*
rm -vf root/usr/bin/{cpack,ctest}
set -e

# TODO: Stateless profile! This is ugly as sin.

cp profile root/etc/profile
docker rmi serpentos/staging:latest || :

docker build --tag serpentos/staging:latest .
