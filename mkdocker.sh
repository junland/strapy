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

# TODO: Stateless profile! This is ugly as sin.

echo "alias ls='ls -F --color=auto'" >> "root/etc/profile"
docker rmi staging || :

docker build --tag staging .
